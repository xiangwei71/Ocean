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
    int kernal;
    int[]  bit_reverse;

    int h = 512;

    int do_bit_reverse (int value, int bit_length) {
        return 0;
    }

    void set_bit_reverse () {
        bit_reverse = new int[h];

        int n = (int) Mathf.Log (h, 2);
        for (var i = 0; i < h; ++i) {
            bit_reverse[i]=do_bit_reverse(i, n);
        }
    }

    // Start is called before the first frame update
    void Start () {
        init_buffer (ref buffer_des, h, h, RenderTextureFormat.RGFloat);
        init_buffer (ref buffer_src, h, h, RenderTextureFormat.RGFloat);

        //特別的設定
        set_bit_reverse ();

        Graphics.Blit(input_texture, buffer_src, Fill);
        Graphics.Blit(buffer_src, buffer_des, Transpose);
        swap_texture(ref buffer_src, ref buffer_des);

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