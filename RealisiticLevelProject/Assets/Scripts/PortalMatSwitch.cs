using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PortalMatSwitch : MonoBehaviour
{
    public Material originalMat;
    Renderer rend;
    public Material blackMat;
    public KeyCode on;
    public KeyCode off;

    void Start()
    {
        rend = GetComponent<Renderer>();

        if(originalMat != null)
        {
            originalMat = rend.material;
        }
    }

    void Update()
    {
        if(Input.GetKeyDown(on))
        {
            rend.material = originalMat;
        }
        else  if(Input.GetKeyDown(off))
        {
            rend.material = blackMat;
        }
    }
}
