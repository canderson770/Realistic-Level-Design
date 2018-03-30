using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightFix : MonoBehaviour
{
    public VolumetricLight light;
    public float delay;
	
    public void Delay()
    {
        StartCoroutine(DoDelay());
    }

    IEnumerator DoDelay()
    {
        light.enabled = false;
        yield return new WaitForSecondsRealtime(delay);
        light.gameObject.SetActive(true);
    }
}
