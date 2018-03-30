using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
public class ParticleSounds : MonoBehaviour
{
    public GameObject audioPrefab;

    ParticleSystem _system;
    ParticleSystem.Particle[] _particles;
    GameObject[] _audiosources;


    void Start()
    {
        _system = GetComponent<ParticleSystem>();
        _particles = new ParticleSystem.Particle[_system.maxParticles];

        _audiosources = new GameObject[_system.maxParticles];
        for (int i = 0; i < _audiosources.Length; i++)
        {
            _audiosources[i] = Instantiate(audioPrefab);
            _audiosources[i].transform.parent = transform;
        }
    }

    void Update()
    {

        int count = _system.GetParticles(_particles);
        for (int i = 0; i < count; i++)
        {
//            _audiosources[i].gameObject.SetActive(true);
            _audiosources[i].transform.localPosition = _particles[i].position;
        }

        for (int i = count; i < _particles.Length; i++)
        {
            _audiosources[i].gameObject.SetActive(false);
        }
    }
}
