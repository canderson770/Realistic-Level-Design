using System.Collections;
using UnityEngine;

public class DeathZone : MonoBehaviour
{
    public float safeHeight;
    private Vector3 safePosition;
    private Quaternion safeRotation;
    private CharacterController cc;
    private Rigidbody rb;

    private void Start()
    {
        cc = GetComponent<CharacterController>();
        rb = GetComponent<Rigidbody>();

        safePosition = transform.localPosition;
        safeRotation = transform.localRotation;

        StartCoroutine(CheckForSafeZone());
    }

    private IEnumerator CheckForSafeZone()
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

    private void OnTriggerEnter(Collider coll)
    {
        if (coll.gameObject.name.Contains("DeathZone"))
        {
            transform.localPosition = new Vector3(safePosition.x, safePosition.y + 2, safePosition.z);
            transform.localRotation = safeRotation;
            rb.velocity = Vector3.zero;
        }
    }
}
