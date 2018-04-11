using UnityEngine;

public class CustomParticleCulling : MonoBehaviour
{
    public float cullingRadius = 10;
    public ParticleSystem[] PS;

    private CullingGroup m_CullingGroup;

    void Start ()
    {
        PS = GetComponentsInChildren<ParticleSystem>();

        m_CullingGroup = new CullingGroup();
        m_CullingGroup.targetCamera = Camera.main;
        m_CullingGroup.SetBoundingSpheres(new BoundingSphere[] { new BoundingSphere(transform.position, cullingRadius) });
        m_CullingGroup.SetBoundingSphereCount(1);
        m_CullingGroup.onStateChanged += OnStateChanged;
    }

    void OnStateChanged(CullingGroupEvent sphere)
    {
        if (sphere.isVisible)
        {
            // We could simulate forward a little here to hide that the system was not updated off-screen.

            foreach (ParticleSystem ps in PS)
            {
                ps.Play(true);
            }
        }
        else
        {
            foreach (ParticleSystem ps in PS)
            {
                ps.Pause();
            }
        }
    }

    void OnDestroy()
    {
        if(m_CullingGroup != null)
            m_CullingGroup.Dispose();
    }

    void OnDrawGizmos()
    {
        // Draw gizmos to show the culling sphere.
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, cullingRadius);
    }
}