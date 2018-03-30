using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeathZone : MonoBehaviour
{
    public float safeHeight;
    Vector3 safePosition;
    Quaternion safeRotation;
    CharacterController cc;
    Rigidbody rb;

    void Start()
    {
        cc = GetComponent<CharacterController>();
        rb = GetComponent<Rigidbody>();

        safePosition = transform.localPosition;
        safeRotation = transform.localRotation;

        StartCoroutine(CheckForSafeZone());
    }

    IEnumerator CheckForSafeZone()
    {
        while (true)
        {
            yield return new WaitForSeconds(.1f);
            if (cc.isGrounded && transform.position.y >= safeHeight)
            {
                safePosition = transform.localPosition;
                safeRotation = transform.localRotation;
            }
        }
    }

   
    void OnTriggerEnter(Collider coll)
    {
        if (coll.gameObject.name.Contains("DeathZone"))
        {
            transform.localPosition = new Vector3(safePosition.x, safePosition.y + 2, safePosition.z);
            transform.localRotation = safeRotation;
            rb.velocity = Vector3.zero;
        }
    }
}
