using UnityEngine;
using System.Collections.Generic;
using System.Runtime.Remoting.Messaging;

public class Game : Scene<Game>
{
    public override Game ThisScene() {
        return this;
    }

    public List<GameObject> ActiveChunks = new List<GameObject>();
    public List<GameObject> ActiveObjects = new List<GameObject>();

    public void AddActiveObjects(List<GameObject> objects) {
        ActiveObjects.AddRange(objects);
    }

    public void AddActiveChunks(List<GameObject> chunks) {
        ActiveChunks.AddRange(chunks);
    }
}
