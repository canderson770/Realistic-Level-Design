using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

/*    ^ TAVOR TEC ^
 * 
 *     FPS Display
 *     
 * 02/25/2018   Version 1.0
 * 
 * Drag and drop the FPS Display prefab into your scene and adjust its position.
 * The display will start inactive and inivisble when the game starts running.
 * It's also setup to persist on scene changes.
 * Remove the DontDestroyOnLoad function call in line 70 if you only need the FPS display in a specific scene
 * with custom parameters for frame buffer, key bindings or other variables.
 * 
*/


public class FPSCounter : MonoBehaviour {

    // Component References
    public LineRenderer m_fpsLine = null;           // The FPS LineRenderer
    public TextMesh m_fpsLowHigh = null;            // TextMesh for lowest FPS rate
    public TextMesh m_frameBufferDisplay = null;    // TextMesh for highest FPS rate

    // Key Bindings
    public KeyCode m_keyActivation = KeyCode.F;     // Activation key. Toggles FPS display visibility
    public KeyCode m_keyReset = KeyCode.R;          // Reset key. Will clear the FPS rate buffer
    public KeyCode m_keyPause = KeyCode.P;          // Pause key. Will pause the FPS display

    private Vector3[] m_fpsRates;                   // FPS frame rates
    private Vector3[] m_bufferRates;                // FPS buffer
    private int m_displayColumns = 100;              // Buffer length

    private float m_maxWidth = 14f;                 // Camera display width
    private float m_columnDistance;                 // Distance between LineRenderer points

    private bool m_isRunning = false;               // Display active inidcator. Change to true if you want the display visible on start up
    private int m_lowFPS = 1000;                    // Lowest FPS value
    private int m_highFPS = 0;                      // Highest FPS value

    private int m_minFrameBuffer = 50;              // Minimum FPS buffer length
    private int m_maxFrameBuffer = 200;             // Maximum FPS buffer length


    void Start()
    {
        // Check-up for script references
        bool t_missingReference = false;
        if (m_fpsLine == null)
        {
            t_missingReference = true;
            Debug.LogError("Missing LineRenderer component reference! Disabling script!");
        }
        if(m_fpsLowHigh == null)
        {
            t_missingReference = true;
            Debug.LogError("Missing TextMesh component reference! Disabling script!");
        }
        if (m_frameBufferDisplay == null)
        {
            t_missingReference = true;
            Debug.LogError("Missing TextMesh component reference! Disabling script!");
        }

        // Better disable script if there's any missing reference
        if(t_missingReference)
        {
            this.enabled = false;
        }
        
        // Otherwise setup the FPS display
        else
        {
            DontDestroyOnLoad(transform.gameObject);    // Makes game object persistant on scene changes
            ResetFPSCounter();
            gameObject.GetComponentInChildren<Camera>().enabled = m_isRunning;
        }

    }

    void Update()
    {
        // Only run FPS calculations if display is running (visible and not paused)
        if(m_isRunning)
        {

            float t_fps = 1f / Time.deltaTime;                                      // FPS calculation
            m_bufferRates = m_fpsRates;                                             // Buffer array setup

            // Loop through FPS rates array and shift their positions
            for(int t_count = 0; t_count < m_fpsRates.Length-1; ++t_count)          
            {
                m_bufferRates[t_count].y = m_fpsRates[t_count + 1].y;
            }

            // Add actual frame rate to last buffer element
            m_bufferRates[m_fpsRates.Length - 1].y =  ( (4f/60f)* t_fps) -3;
            
            // Assign buffer to FPS rates array
            m_fpsRates = m_bufferRates;

            // Update LineRenderer positions
            m_fpsLine.SetPositions(m_fpsRates);

            // Check for low and high FPS rates
            bool t_change = false;
            if (t_fps > m_highFPS)              // High FPS changed
            {
                m_highFPS = (int)t_fps;
                t_change = true;
            }
            if (t_fps < m_lowFPS)               // Low FPS changed
            {
                m_lowFPS = (int)t_fps;
                t_change = true;
            }

            // Change low/high FPS if needed
            if (t_change)
            {
                m_fpsLowHigh.text = m_lowFPS + " / " + m_highFPS;
            }
        }

        // Check for user inputs
        if (Input.GetKeyDown(m_keyActivation))          // Activation Key
        {
            m_isRunning = !m_isRunning;

            gameObject.GetComponentInChildren<Camera>().enabled = m_isRunning;
        }
        else if (Input.GetKeyDown(m_keyReset))          // Reset Key
        {
            m_lowFPS = 1000;
            m_highFPS = 0;
            ResetFPSCounter();
        }
        else if(Input.GetKeyDown(m_keyPause) &&         // Pause Key. Only works if camera is enabled
                gameObject.GetComponentInChildren<Camera>().enabled)
        {
            m_isRunning = !m_isRunning;
        }
        else if (Input.GetKeyDown(KeyCode.KeypadMinus)) // Decrease Buffer Key
        {
            if(m_displayColumns >= m_minFrameBuffer)
            {
                m_displayColumns /= 2;
                ResetFPSCounter();
            }
        }
        else if(Input.GetKeyDown(KeyCode.KeypadPlus))   // Increase Buffer Key
        {
            if (m_displayColumns <= m_maxFrameBuffer)   
            {
                m_displayColumns *= 2;
                ResetFPSCounter();
            }
        }
    }

    /// <summary>
    /// Resets the FPS frame buffer and LineRenderer
    /// </summary>
    void ResetFPSCounter()
    {
        // Calculate distance between LineRenderer points
        m_columnDistance = m_maxWidth / m_displayColumns;
        // Initialize FPS rates array
        m_fpsRates = new Vector3[m_displayColumns];

        // Loop through FPS rates array and set each point to 0 FPS
        for (int t_count = 0; t_count < m_fpsRates.Length; ++t_count)
        {
            m_fpsRates[t_count].Set(-(m_maxWidth * 0.5f) + (t_count * m_columnDistance), -3, 0.5f);

        }

        // Update LineRenderer positions
        m_fpsLine.numPositions = m_displayColumns;
        m_fpsLine.SetPositions(m_fpsRates);

        // Assign FPS rates array to buffer
        m_bufferRates = new Vector3[m_displayColumns];
        // Update frame buffer text
        m_frameBufferDisplay.text = m_displayColumns.ToString();
    }
}

// THE END!
