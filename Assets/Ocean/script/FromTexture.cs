using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FromTexture : MonoBehaviour {
    public Material mat;
    public ComputeShader shader;
    public RenderTexture buffer_des;
    public RenderTexture buffer_src;
    public Texture2D input_texture;
    int kernal;

    int h = 512;
    ComputeBuffer bit_reverse;

    public string reverse_str (string s) {
        char[] char_array = s.ToCharArray ();
        Array.Reverse (char_array);
        return new string (char_array);
    }

    int do_bit_reverse (int value, int bit_length) {
        var bit_str = Convert.ToString (value, 2);

        //補0
        if (bit_str.Length != bit_length)
            bit_str = bit_str.PadLeft (bit_length, '0');

        var bit_str_reverse = reverse_str (bit_str);
        // Debug.Log(bit_str + "," + bit_str_reverse);
        return Convert.ToUInt16 (bit_str_reverse, 2);
    }

    struct Bit_Reverse_Buffer {
        public int index;
    };

    void set_bit_reverse () {
        bit_reverse = new ComputeBuffer (h, 4);

        int n = (int) Mathf.Log (h, 2);
        var buffer = new Bit_Reverse_Buffer[h];
        for (var i = 0; i < h; ++i) {
            buffer[i] = new Bit_Reverse_Buffer ();
            buffer[i].index = do_bit_reverse (i, n);
        }

        bit_reverse.SetData (buffer);
        shader.SetBuffer (kernal, "bit_reverse", bit_reverse);
    }

    // Start is called before the first frame update
    void Start () {
        init_buffer (ref buffer_des, h, h, RenderTextureFormat.RGFloat);
        init_buffer (ref buffer_src, h, h, RenderTextureFormat.RGFloat);

        kernal = shader.FindKernel ("CSMain");
        shader.SetTexture (kernal, "input_texture", input_texture);
        shader.SetTexture (kernal, "buffer_des", buffer_des);
        shader.SetTexture (kernal, "buffer_src", buffer_src);

        set_bit_reverse ();

        mat.SetTexture ("_MainTex", buffer_des);
    }

    void init_buffer (ref RenderTexture buffer, int w, int h, RenderTextureFormat format) {
        buffer = new RenderTexture (w, h, 0, format);
        buffer.enableRandomWrite = true;
        buffer.Create ();
    }

    // Update is called once per frame
    void Update () {
        shader.Dispatch (kernal, 512 / 8, 512 / 8, 1);
    }

    private void OnDisable () {
        bit_reverse.Release ();
    }
}