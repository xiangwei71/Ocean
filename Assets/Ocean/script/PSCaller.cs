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

        butterfly(ref buffer_src, ref buffer_des);


        //Graphics.Blit(buffer_src, buffer_des, Transpose);
        //swap_texture(ref buffer_src, ref buffer_des);



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
        // 蝴蝶算法的第1步:交換位置
        Graphics.Blit(b1, b2, set_element_order_per_column);
        swap_texture(ref b1, ref b2);

        var n = Mathf.Log(h,2);
        Debug.Log(n);
        var n_minus_1 = (int)n - 1;
        for (var order = 0; order< n_minus_1; ++order) {
            add_or_minus.SetInt("_order", order);
            Graphics.Blit(b1, b2, add_or_minus);
            swap_texture(ref b1, ref b2);

            multiply_weight.SetInt("_order", order+1);
            Graphics.Blit(b1, b2, multiply_weight);
            swap_texture(ref b1, ref b2);
        }

        add_or_minus.SetInt("_order", n_minus_1);
        Graphics.Blit(b1, b2, add_or_minus);
        swap_texture(ref b1, ref b2);
    }

// Update is called once per frame
void Update () {
    }
}