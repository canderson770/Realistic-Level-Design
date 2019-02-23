using System.Collections;
using UnityEngine;

public class SnowAmount : MonoBehaviour
{
    private MeshRenderer mr;
    private Material snowMat;

    public bool isSnowing = true;
    private float snowSpeed = .001f;
    private float startSnowAmount;
    private float currentSnowAmount;

    private void OnEnable()
    {
        SnowSettings.SetSnowSpeed += SetSpeed;
    }

    private void OnDisable()
    {
        SnowSettings.SetSnowSpeed -= SetSpeed;
    }

    private void SetSpeed(float _speed)
    {
        snowSpeed = _speed;
    }

    private void Start()
    {
        mr = GetComponent<MeshRenderer>();

        if (mr != null)
        {
            snowMat = mr.material;
        }

        if (snowMat != null)
        {
            startSnowAmount = snowMat.GetFloat("_LayerStrength");
        }

        StartCoroutine(Snow());
    }

    private IEnumerator Snow()
    {
        while (isSnowing)
        {
            yield return new WaitForSeconds(1);

            if (snowMat != null)
            {
                currentSnowAmount = snowMat.GetFloat("_LayerStrength");
                snowMat.SetFloat("_LayerStrength", currentSnowAmount + snowSpeed);
            }
        }
    }
}
