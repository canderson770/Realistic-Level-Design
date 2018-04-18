using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogControl : MonoBehaviour
{
    public void Fog(bool _active)
    {
        RenderSettings.fog = _active;
    }
}
