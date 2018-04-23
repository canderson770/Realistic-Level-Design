using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogControlCamera : MonoBehaviour
{
    public bool enableFog = true;

    bool previousFogState;

    void OnPreRender()
    {
        previousFogState = RenderSettings.fog;
        RenderSettings.fog = enableFog;
    }

    void OnPostRender()
    {
        RenderSettings.fog = previousFogState;            
    }
}
