using UnityEngine;
using System.Collections;

public abstract class Scene<T> : IScenable
{
    public bool DEBUG = false;
    public abstract T ThisScene();
}