using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
public class ParticleSounds : MonoBehaviour
{
    public GameObject audioPrefab;
    private ParticleSystem ps;
    private ParticleSystem.Particle[] particles;
    private GameObject[] sources;

    private void Start()
    {
        ps = GetComponent<ParticleSystem>();
        particles = new ParticleSystem.Particle[ps.main.maxParticles];

        sources = new GameObject[ps.main.maxParticles];
        for (int i = 0; i < sources.Length; i++)
        {
            sources[i] = Instantiate(audioPrefab);
            sources[i].transform.parent = transform;
        }
    }

    private void Update()
    {

        int count = ps.GetParticles(particles);
        for (int i = 0; i < count; i++)
        {
            sources[i].transform.localPosition = particles[i].position;
        }

        for (int i = count; i < particles.Length; i++)
        {
            sources[i].gameObject.SetActive(false);
        }
    }
}
