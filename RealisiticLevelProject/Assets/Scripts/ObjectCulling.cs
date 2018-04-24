using UnityEngine;
using UnityEngine.Events;

public class ObjectCulling : MonoBehaviour
{
    public bool showInSceneView = true;
    public float cullingRadius = 10;
    public Transform[] objectsToCull;

    private CullingGroup cullingGroup;

    void Start()
    {
        objectsToCull = GetComponentsInChildren<Transform>();

        cullingGroup = new CullingGroup();
        cullingGroup.targetCamera = Camera.main;
        cullingGroup.SetBoundingSpheres(new BoundingSphere[] { new BoundingSphere(transform.position, cullingRadius) });
        cullingGroup.SetBoundingSphereCount(1);
        cullingGroup.onStateChanged += OnStateChanged;
    }

    void OnStateChanged(CullingGroupEvent sphere)
    {
        if (sphere.isVisible)
        {
            foreach (Transform obj in objectsToCull)
            {
                obj.gameObject.SetActive(true);
            }
        }
        else
        {
            foreach (Transform obj in objectsToCull)
            {
                obj.gameObject.SetActive(false);
            }
        }
    }

    void OnDestroy()
    {
        if (cullingGroup != null)
            cullingGroup.Dispose();
    }

    void OnDrawGizmos()
    {
        if (showInSceneView)
        {
            Gizmos.color = Color.yellow;
            Gizmos.DrawWireSphere(transform.position, cullingRadius);
        }
    }
}