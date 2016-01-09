using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ChunkSpawner : MonoBehaviour {

    public List<GameObject> ChunkTypes;
    public int MapSize;
    public float Seed, ChunkSize;

    private List<Vector3> _possibleChunkPositions = new List<Vector3>();
    private List<GameObject> currentChunks = new List<GameObject>();

	// Use this for initialization
	void Start () {
        _possibleChunkPositions.Clear();
        currentChunks.Clear();

        Seed = Random.value;

        _possibleChunkPositions = UnityTools.PointsInsideCircle(MapSize, 1, ChunkSize, 0);
        StartCoroutine(ChunkPlacer());
	}

    IEnumerator ChunkPlacer() {
        foreach(Vector3 pos in _possibleChunkPositions){
/*            float density1 = (float)PerlinNoise.Noise(pos.x / 300f, pos.y / 300f, Seed) * ChunkTypes.Count + 1;
            int density = Mathf.FloorToInt(Mathf.Abs(density1));
            density = (density >= ChunkTypes.Count) ? ChunkTypes.Count-1 : density;
            densityMap.Add(pos, density);*/
            currentChunks.Add(SpawnChunk(pos));
            
            if (1.0f / Time.deltaTime < 50) {
                Debug.Log("Buffering load for better FPS");
                yield return null;
            }
        }
        Master.M.S.AddActiveObjects(currentChunks);

    }

    private GameObject SpawnChunk(Vector3 position) {
        GameObject thisChunk = Instantiate(ChunkTypes[0], position, Quaternion.identity) as GameObject;
        //thisChunk.GetComponent<TerrainGenerator>().starCount = density;
        thisChunk.transform.parent = Master.M.transform;
        return thisChunk;
    }
}
