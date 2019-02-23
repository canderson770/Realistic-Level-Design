using UnityEngine;

public class TextureSetup : MonoBehaviour
{
    public Camera camera1;
    public Camera camera2;

    public Material camera1Mat;
    public Material camera2Mat;

    // When game starts remove current camera textures and set new textures with the dimensions of the players screen
    private void Start()
    {
        camera1.targetTexture = new RenderTexture(Screen.width, Screen.height, 24);
        camera1Mat.mainTexture = camera1.targetTexture;

        camera2.targetTexture = new RenderTexture(Screen.width, Screen.height, 24);
        camera2Mat.mainTexture = camera2.targetTexture;
    }
}
