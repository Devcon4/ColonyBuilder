using UnityEngine;
using System;
using System.Collections.Generic;

public class Master : MonoBehaviour {
    public static Master M;
    public Game S = new Game();

    void Awake() {
        if (M == null) {
            DontDestroyOnLoad(gameObject);
            M = this;

        } else if (M != this) {
            Destroy(gameObject);
        }
    }
}

