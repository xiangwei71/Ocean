using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class PSCaller : MonoBehaviour {
    public Material mat;
    public RenderTexture buffer_des;
    public RenderTexture buffer_src;
    public Texture2D input_texture;

    public Material Fill;
    public Material Transpose;
    public Material set_element_order_per_column;
    public Material add_or_minus;
    public Material multiply_weight;

    int h = 512;

    // Start is called before the first frame update
    void Start () {
        init_buffer (ref buffer_des, h, h, RenderTextureFormat.RGFloat);
        init_buffer (ref buffer_src, h, h, RenderTextureFormat.RGFloat);

        // fill image
        Graphics.Blit(input_texture, buffer_src, Fill);

        FFT(ref buffer_src, ref buffer_des);

        mat.SetTexture("_MainTex", buffer_src);
    }

    void init_buffer (ref RenderTexture buffer, int w, int h, RenderTextureFormat format) {
        buffer = new RenderTexture (w, h, 0, format);
        buffer.enableRandomWrite = true;
        buffer.Create ();
    }

    void swap_texture(ref RenderTexture b1,ref RenderTexture b2) {
        RenderTexture temp = b1;
        b1 = b2;
        b2 = temp;
    }

    void butterfly(ref RenderTexture b1, ref RenderTexture b2)
    {
        // FFT蝴蝶算法
        // https://developer.nvidia.com/sites/all/modules/custom/gpugems/books/GPUGems2/elementLinks/48_fft_01.jpg?fbclid=IwAR2H-0eU76Zdzrvrn_MPJDliacIK6MSIuLEh060NvqEWKjb1Zxnvb2el7mQ

        // 蝴蝶算法的第1步:交換位置
        do_set_element_order_per_column(ref b1, ref b2);

         var n = Mathf.Log(h,2);
        var n_minus_1 = (int)n - 1;
        for (var order = 0; order< n_minus_1; ++order) {
            do_add_or_minus(ref b1, ref b2, order);
            do_multiply_weight(ref b1, ref b2, order+1);
        }

       do_add_or_minus(ref  b1, ref  b2, n_minus_1); 
    }

    void do_set_element_order_per_column(ref RenderTexture b1, ref RenderTexture b2)
    {
        Graphics.Blit(b1, b2, set_element_order_per_column);
        swap_texture(ref b1, ref b2);
    }

    void do_multiply_weight(ref RenderTexture b1, ref RenderTexture b2, int order) 
    {
        multiply_weight.SetInt("_order", order);
        Graphics.Blit(b1, b2, multiply_weight);
        swap_texture(ref b1, ref b2);
    }

    void do_add_or_minus(ref RenderTexture b1, ref RenderTexture b2,int order)
    {
        add_or_minus.SetInt("_order", order);
        Graphics.Blit(b1, b2, add_or_minus);
        swap_texture(ref b1, ref b2);
    }

    void FFT(ref RenderTexture b1, ref RenderTexture b2)
    {
        /*二維DFT可以分解成 2次一維DFT
        B=MX
        Y=M(B)T
        */
        butterfly(ref b1, ref b2);

        // transpose
        Graphics.Blit(b1, b2, Transpose);
        swap_texture(ref b1, ref b2);

        butterfly(ref b1, ref b2);
    }

// Update is called once per frame
void Update () {
    }
}