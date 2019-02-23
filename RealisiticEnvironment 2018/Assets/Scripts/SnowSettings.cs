using UnityEngine;
using System;

public class SnowSettings : MonoBehaviour
{
    public static Action<float> SetSnowSpeed;
    public float speed = .001f;

    private void Start()
    {
        if (SetSnowSpeed != null)
            SetSnowSpeed(speed);
    }
}
