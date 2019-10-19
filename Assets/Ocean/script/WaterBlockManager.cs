using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterBlockManager : MonoBehaviour
{
    List<Material> mat_list;
    public GameObject water_block;
    void Awake()
    {
        mat_list = new List<Material>();
        var h = 1;
        var space = 2;
        for (var x = 0; x < h; ++x) {
            for (var y = 0; y < h; ++y)
            {
                var block=GameObject.Instantiate<GameObject>(water_block, transform);
                block.transform.localPosition = new Vector3(space * x, 0, space*y);

                var m_renders=block.GetComponentsInChildren<MeshRenderer>();
                foreach (var m_render in m_renders) {
                    var mat = m_render.material;
                    mat.SetVector("_block_offset", new Vector4(x, y, 0, 0));
                    mat_list.Add(mat);
                }
            }
        }
    }

    public void update_blockss(ref RenderTexture tex) {
        foreach (var mat in mat_list)
        {
            mat.SetTexture("_MainTex", tex);
        }
    }
}
