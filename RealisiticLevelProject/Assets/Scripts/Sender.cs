using UnityEngine;
using System.Collections;
using UnityEngine.Events;

public class Sender : MonoBehaviour
{

    public GameObject player;
    public GameObject receiver;

    private float prevDot = 0;
    private bool playerOverlapping = false;

    public Trigger triggerEvents;
    public UnityEvent OnTeleport;

    void Update()
    {
        if (playerOverlapping)
        {
            var currentDot = Vector3.Dot(transform.up, player.transform.position - transform.position);

            if (currentDot < 0) // only transport the player once he's moved across plane
            {
                // transport him to the equivalent position in the other portal
                float rotDiff = -Quaternion.Angle(transform.rotation, receiver.transform.rotation);
                rotDiff += 180;
                player.transform.Rotate(Vector3.up, rotDiff);

                Vector3 positionOffset = player.transform.position - transform.position;
                positionOffset = Quaternion.Euler(0, rotDiff, 0) * positionOffset;
                var newPosition = receiver.transform.position + positionOffset;
                player.transform.position = newPosition;

                playerOverlapping = false;

                OnTeleport.Invoke();
            }
               
            prevDot = currentDot;
        }
    }


    void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            playerOverlapping = true;

            triggerEvents.onTriggerEnter.Invoke();
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            playerOverlapping = false;

            triggerEvents.onTriggerExit.Invoke();
        }
    }
}
