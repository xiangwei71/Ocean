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
    public Material Shift;
    public Material multiply;
    public Material PhillipsSpectrum;
    public Material cos_wave;
    public Material Stich_left_right;
    public Material Stich_up_down;

    public WaterBlockManager [] water_block_manager;

    int h = 512;

    // Start is called before the first frame update
    void Start () {
        init_buffer (ref buffer_des, h, h, RenderTextureFormat.RGFloat);
        init_buffer (ref buffer_src, h, h, RenderTextureFormat.RGFloat);
    }

    void update_texture() { 

        mat.SetTexture("_MainTex", buffer_src);
        foreach (var m in water_block_manager)
            m.update_blocks(ref buffer_src);
    }

    // Update is called once per frame
    void Update()
    {
        I_still_not_understand_PhillipsSpectrum();
        //test_cos_wave();
        //check_FFT_and_IFFT_result();

        update_texture();
    }

    void test_cos_wave() {
        Graphics.Blit(null, buffer_src, cos_wave);
        //FFT(ref buffer_src, ref buffer_des);
        //do_Shift(ref buffer_src, ref buffer_des);
    }

    void I_still_not_understand_PhillipsSpectrum() {
        Graphics.Blit(null, buffer_src, PhillipsSpectrum);
        do_Shift(ref buffer_src, ref buffer_des);
        Inverse_FFT(ref buffer_src, ref buffer_des, false);
        do_Stich_left_right(ref buffer_src, ref buffer_des);
        do_Stich_up_down(ref buffer_src, ref buffer_des);
    }

    void do_Stich_left_right(ref RenderTexture b1, ref RenderTexture b2)
    {
        Graphics.Blit(b1, b2, Stich_left_right);
        swap_texture(ref b1, ref b2);
    }

    void do_Stich_up_down(ref RenderTexture b1, ref RenderTexture b2)
    {
        Graphics.Blit(b1, b2, Stich_up_down);
        swap_texture(ref b1, ref b2);
    }

    //測式IFFT是正確的
    void check_FFT_and_IFFT_result() {
        // fill image
        Graphics.Blit(input_texture, buffer_src, Fill);

        FFT(ref buffer_src, ref buffer_des);
        //do_Shift(ref buffer_src, ref buffer_des);
        Inverse_FFT(ref buffer_src, ref buffer_des,true);
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

    void butterfly(ref RenderTexture b1, ref RenderTexture b2,bool is_inverse)
    {
        // FFT蝴蝶算法
        // https://developer.nvidia.com/sites/all/modules/custom/gpugems/books/GPUGems2/elementLinks/48_fft_01.jpg?fbclid=IwAR2H-0eU76Zdzrvrn_MPJDliacIK6MSIuLEh060NvqEWKjb1Zxnvb2el7mQ

        // 蝴蝶算法的第1步:交換位置
        do_set_element_order_per_column(ref b1, ref b2);

         var n = Mathf.Log(h,2);
        var n_minus_1 = (int)n - 1;
        for (var order = 0; order< n_minus_1; ++order) {
            do_add_or_minus(ref b1, ref b2, order);
            do_multiply_weight(ref b1, ref b2, order+1, is_inverse);
        }

       do_add_or_minus(ref  b1, ref  b2, n_minus_1); 
    }

    void do_Shift(ref RenderTexture b1, ref RenderTexture b2)
    {
        Graphics.Blit(b1, b2, Shift);
        swap_texture(ref b1, ref b2);
    }

    void do_set_element_order_per_column(ref RenderTexture b1, ref RenderTexture b2)
    {
        Graphics.Blit(b1, b2, set_element_order_per_column);
        swap_texture(ref b1, ref b2);
    }

    void do_multiply_weight(ref RenderTexture b1, ref RenderTexture b2, int order,bool is_inverse) 
    {
        multiply_weight.SetFloat("_rotate", is_inverse ? -1.0f : 1.0f);
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
        butterfly(ref b1, ref b2,false);
        do_Transpose(ref b1, ref b2);
        butterfly(ref b1, ref b2, false);
    }

    void Inverse_FFT(ref RenderTexture b1, ref RenderTexture b2,bool do_divide) {
        butterfly(ref b1, ref b2,true);
        do_Transpose(ref b1, ref b2);
        butterfly(ref b1, ref b2,true);

        if(do_divide)
            do_multiply(ref b1, ref b2);
    }

    void do_Transpose(ref RenderTexture b1, ref RenderTexture b2) {
        // transpose
        Graphics.Blit(b1, b2, Transpose);
        swap_texture(ref b1, ref b2);
    }

    void do_multiply(ref RenderTexture b1, ref RenderTexture b2) {
        multiply.SetFloat("_factor", 1.0f/(h*h));
        Graphics.Blit(b1, b2, multiply);
        swap_texture(ref b1, ref b2);
    }
}