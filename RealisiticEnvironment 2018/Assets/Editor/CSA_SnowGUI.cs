using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class CSA_SnowGUI : ShaderGUI
{
    MaterialEditor m_editor;
    MaterialProperty[] m_props;
    static GUIContent staticLabel = new GUIContent();

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        m_editor = materialEditor;
        m_props = props;

        ShaderPropertiesGUI();
    }

    private void ShaderPropertiesGUI()
    {
        MaterialProperty tess = FindProperty("_Tess");
        if (tess != null)
            m_editor.ShaderProperty(tess, MakeLabel(tess));
        // ======================================================================

        GUILayout.Label("Main Maps", EditorStyles.boldLabel);

        MaterialProperty mainTex = FindProperty("_MainTex");
        MaterialProperty normalMap = FindProperty("_BumpMap");
        MaterialProperty matchTiling = FindProperty("_MatchTiling");

        if (mainTex != null && matchTiling != null)
        {
            m_editor.TexturePropertySingleLine(MakeLabel(mainTex, "Albedo, Tint, and Toggle for unique map tiling"), mainTex, FindProperty("_Color"), matchTiling);

            if (matchTiling.floatValue == 1)            
                m_editor.TextureScaleOffsetProperty(mainTex);
        }      
        if (normalMap != null && matchTiling != null)
        {
            m_editor.TexturePropertySingleLine(MakeLabel(normalMap), normalMap, normalMap.textureValue ? FindProperty("_BumpScale") : null);

            if (matchTiling.floatValue == 1)
                m_editor.TextureScaleOffsetProperty(normalMap);
            else          
                m_editor.TextureScaleOffsetProperty(mainTex);
        }

        // ======================================================================
        AddSpace(1);

        GUILayout.Label("Snow Maps", EditorStyles.boldLabel);   

        MaterialProperty snowMainTex = FindProperty("_SnowTex");
//        MaterialProperty snowPrintsTex = FindProperty("_PaintMap");
        MaterialProperty snowNormalMap = FindProperty("_SnowBump");
        MaterialProperty snowMatchTiling = FindProperty("_SnowMatchTiling");

        if (snowMainTex != null && snowMatchTiling != null)
        {
            m_editor.TexturePropertySingleLine(MakeLabel(snowMainTex, "Snow albedo, Tint, and Toggle for unique map tiling"), snowMainTex, FindProperty("_SnowColor"), snowMatchTiling);
//            m_editor.TexturePropertySingleLine(MakeLabel(snowPrintsTex), snowPrintsTex,);

            if (snowMatchTiling.floatValue == 1) 
                m_editor.TextureScaleOffsetProperty(snowMainTex);
        }
        if (snowNormalMap != null && snowMatchTiling != null)
        {
            m_editor.TexturePropertySingleLine(MakeLabel(snowNormalMap), snowNormalMap, snowNormalMap.textureValue ? FindProperty("_SnowBumpScale") : null);

            if (snowMatchTiling.floatValue == 1)
                m_editor.TextureScaleOffsetProperty(snowNormalMap);
            else
                m_editor.TextureScaleOffsetProperty(snowMainTex);
        }

        // =====================================================================
        AddSpace(1);

        GUILayout.Label("Snow Options", EditorStyles.boldLabel);   

        MaterialProperty snowAmount = FindProperty("_SnowAmount");
        if (snowAmount != null)
            m_editor.ShaderProperty(snowAmount, MakeLabel(snowAmount));

        MaterialProperty snowDepth = FindProperty("_SnowDepth");
        if (snowDepth != null)
            m_editor.ShaderProperty(snowDepth, MakeLabel(snowDepth));

        MaterialProperty snowDirection = FindProperty("_SnowDirection");
        if (snowDirection != null)
            m_editor.ShaderProperty(snowDirection, MakeLabel(snowDirection));

        AddSpace(1);
        GUILayout.Label("Advanced Options", EditorStyles.boldLabel);

        MaterialProperty cullMode = FindProperty("_CullMode");
        if (cullMode != null)
            m_editor.ShaderProperty(cullMode, MakeLabel(cullMode));
        
        MaterialProperty zTest = FindProperty("_ZTest");
        if (zTest != null)
            m_editor.ShaderProperty(zTest, MakeLabel(zTest));

        m_editor.RenderQueueField();
        m_editor.EnableInstancingField();
        m_editor.DoubleSidedGIField();
    }

    private MaterialProperty FindProperty(string name)
    {
        return FindProperty(name, m_props);
    }

    private static GUIContent MakeLabel(string text, string tooltip = null, string offset = null)
    {
        staticLabel.text = offset + text;
        staticLabel.tooltip = tooltip;
        if (tooltip == null)
            staticLabel.tooltip = text;

        return staticLabel;
    }

    private static GUIContent MakeLabel(MaterialProperty property, string tooltip = null, string offset = null)
    {
        staticLabel.text = offset + property.displayName;
        staticLabel.tooltip = tooltip;
        if (tooltip == null)
            staticLabel.tooltip = property.displayName;

        return staticLabel;
    }

    private void AddSpace(int amountOfSpaces)
    {
        for (int i = 0; i < amountOfSpaces; i++)
        {
            EditorGUILayout.Space();
        }
    }
}
