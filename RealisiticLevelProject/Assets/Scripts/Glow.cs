using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Glow : MonoBehaviour
{
    public bool enabled = true;
    public bool randomSelection = false;
    public List<Texture> emissionMaps;
    public float frequency = .1f;

    private Material thisMaterial;
    private int randomValue = 0;

    void Start()
    {
        if (thisMaterial == null)
            thisMaterial = GetComponent<MeshRenderer>().material;

//        if (enabled)
//            StartChanging();
    }

    public void StartChanging()
    {
        StartCoroutine(ChangeEmissonMap());

    }

    public void StopChanging()
    {
        StopAllCoroutines();
    }

    IEnumerator ChangeEmissonMap()
    {
        while (enabled && emissionMaps.Count > 0)
        {
            if (randomSelection)
                randomValue = Random.Range(0, emissionMaps.Count);
            else
                randomValue = (randomValue + 1) % emissionMaps.Count;

            thisMaterial.SetTexture("_EmissionMap", emissionMaps[randomValue]);

            yield return new WaitForSeconds(frequency);
        }
    }
}
