using UnityEngine;
using UnityEngine.Events;

public class PortalCulling : MonoBehaviour
{
    public float cullingRadius = 10;

    public UnityEvent OnVisible;
    public UnityEvent OnNotVisible;

    private CullingGroup cullingGroup;

    void Start ()
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
            OnVisible.Invoke();
        }
        else
        {
            OnNotVisible.Invoke();
        }
    }

    void OnDestroy()
    {
        if(cullingGroup != null)
            cullingGroup.Dispose();
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, cullingRadius);
    }
}