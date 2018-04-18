using UnityEngine;
using UnityEngine.Events;

[System.Serializable]
public class VisibilityEvents
{
    public UnityEvent OnVisible;
    public UnityEvent OnNotVisible;
}

public class PortalCulling : MonoBehaviour
{
    public bool showInSceneView = true;
    public float cullingRadius = 10;
    public GameObject[] objectsToCull;
    public VisibilityEvents events;

    private CullingGroup cullingGroup;

    void Start()
    {
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
            foreach (GameObject obj in objectsToCull)
            {
                obj.SetActive(true);
            }

            events.OnVisible.Invoke();
        }
        else
        {
            foreach (GameObject obj in objectsToCull)
            {
                obj.SetActive(false);
            }

            events.OnNotVisible.Invoke();
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