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
    public bool isEnabled = true;
    public string triggerName;

    [SerializeField]
    public Trigger triggerEvents;

    private void OnTriggerEnter(Collider coll)
    {
        if (isEnabled)
        {
            if (coll.name.Contains(triggerName))
            {
                triggerEvents.onTriggerEnter.Invoke();
            }
        }
    }

    private void OnTriggerExit(Collider coll)
    {
        if (isEnabled)
        {
            if (coll.name.Contains(triggerName))
            {
                triggerEvents.onTriggerExit.Invoke();
            }
        }
    }
}
