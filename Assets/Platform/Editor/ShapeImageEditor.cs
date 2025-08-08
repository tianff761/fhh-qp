using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using UnityEditor.UI;

[CustomEditor(typeof(ShapeImage), true)]
public class ShapeImageEditor : ImageEditor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        ShapeImage image = (ShapeImage)target;
        SerializedProperty sp = serializedObject.FindProperty("offset");
        EditorGUILayout.PropertyField(sp, new GUIContent("offset 倾斜偏移"));
        serializedObject.ApplyModifiedProperties();
    }

}
