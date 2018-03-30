using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class SnowSettings : MonoBehaviour
{
    public static Action<float> SetSnowSpeed;
    public float speed = .001f;

    void Start()
    {
        if(SetSnowSpeed != null)
        {
            SetSnowSpeed(speed);
        }
    }
	
}
