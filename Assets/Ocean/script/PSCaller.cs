﻿using System;
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

        Graphics.Blit(input_texture, buffer_src, Fill);

        multiply_weight.SetInt("_order",8);
        Graphics.Blit(buffer_src, buffer_des, multiply_weight);

        //add_or_minus.SetInt("_order", 0);
        //Graphics.Blit(buffer_src, buffer_des, add_or_minus);
        //swap_texture(ref buffer_src, ref buffer_des);

        //Graphics.Blit(buffer_src, buffer_des, set_element_order_per_column);
        //swap_texture(ref buffer_src, ref buffer_des);

        //Graphics.Blit(buffer_src, buffer_des, Transpose);
        //swap_texture(ref buffer_src, ref buffer_des);

        mat.SetTexture("_MainTex", buffer_des);
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

    // Update is called once per frame
    void Update () {
    }
}