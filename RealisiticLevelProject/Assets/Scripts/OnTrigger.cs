using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

[System.Serializable]
public class Trigger
{
    public UnityEvent onTriggerEnter;
    public UnityEvent onTriggerExit;
}

public class OnTrigger : MonoBehaviour
{
    [Space(10)]
    public bool enabled = true;
    public string triggerName;

    [SerializeField]
    public Trigger triggerEvents;

    void OnTriggerEnter(Collider coll)
    {
        if (enabled)
        {
            if (coll.name.Contains(triggerName))
            {
                triggerEvents.onTriggerEnter.Invoke();
            }
        }
    }

    void OnTriggerExit(Collider coll)
    {
        if (enabled)
        {
            if (coll.name.Contains(triggerName))
            {
                triggerEvents.onTriggerExit.Invoke();
            }
        }
    }
}
