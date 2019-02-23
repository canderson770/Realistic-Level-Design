using UnityEngine;

public class PortalCameraFix : MonoBehaviour
{
    public Camera portalCamera;
    public LayerMask originalMask;
    public LayerMask everthingMask;

    public void ShowEverthing()
    {
        portalCamera.cullingMask = everthingMask;
    }

    public void ShowOriginal()
    {
        portalCamera.cullingMask = originalMask;
    }
}
