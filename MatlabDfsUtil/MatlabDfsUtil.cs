using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using DHI.Generic.MikeZero.DFS;

namespace MatlabDfsUtil
{

  /// <summary>
  /// Utility and extension methods for various operations that are slow in Matlab
  /// </summary>
  public static class DfsUtil
  {
    /// <summary>
    /// Bulk read the times and data for a dfs0 file, putting it all in
    /// a matrix structure.
    /// <para>
    /// First column in the result are the times, then a column for each 
    /// item in the file. There are as many rows as there are timesteps.
    /// All item data are converted to doubles.
    /// </para>
    /// </summary>
    public static double[,] ReadDfs0DataDouble(IDfsFile dfs0File)
    {
      int itemCount = dfs0File.ItemInfo.Count;
      int timestepCount = dfs0File.FileInfo.TimeAxis.NumberOfTimeSteps;
      double[,] res = new double[timestepCount,itemCount+1];

      // Preload a set of item data
      IDfsItemData[] itemDatas = new IDfsItemData[itemCount];
      for (int j = 0; j < itemCount; j++)
      {
        itemDatas[j] = dfs0File.CreateEmptyItemData(j+1);
      }
      dfs0File.Reset();

      for (int i = 0; i < timestepCount; i++)
      {
        for (int j = 0; j < itemCount; j++)
        {
          IDfsItemData itemData = itemDatas[j];
          dfs0File.ReadItemTimeStep(itemData, i);
          // First column is time, remaining colums are data
          if (j == 0)
          {
            res[i, 0] = itemData.TimeInSeconds(dfs0File.FileInfo.TimeAxis);
          }
          res[i, j+1] = Convert.ToDouble(itemData.Data.GetValue(0));
        }
      }
      return (res);
    }

    /// <summary>
    /// Bulk write the times and data for a dfs0 file.
    /// <para>
    /// The <paramref name="data"/> contains a column for each 
    /// item in the file. There are as many rows as there are timesteps.
    /// </para>
    /// </summary>
    public static void WriteDfs0DataDouble(IDfsFile dfs0File, double[] times, double[,] data)
    {
      int itemCount = dfs0File.ItemInfo.Count;

      if (times.Length != data.GetLength(0))
        throw new ArgumentException("Number of time steps does not match number of data rows");

      if (itemCount != data.GetLength(1))
        throw new ArgumentException("Number of items does not match number of data columns");

      bool[] isFloatItem = new bool[itemCount];
      for (int j = 0; j < itemCount; j++)
      {
        isFloatItem[j] = dfs0File.ItemInfo[j].DataType == DfsSimpleType.Float;
      }

      float[] fdata = new float[1];
      double[] ddata = new double[1];

      for (int i = 0; i < times.Length; i++)
      {
        for (int j = 0; j < itemCount; j++)
        {
          if (isFloatItem[j])
          {
            fdata[0] = (float)data[i, j];
            dfs0File.WriteItemTimeStepNext(times[i], fdata);
          }
          else
          {
            ddata[0] = data[i, j];
            dfs0File.WriteItemTimeStepNext(times[i], ddata);
          }
        }
      }
    }

    /// <summary>
    /// Convert the element table from a dfsu file to 
    /// a 2D matrix, i.e. from a int[][] to a int[,]. 
    /// In case of mixed elements (triangles/quadrilaterals)
    /// the elements will not have the same number of nodes.
    /// The output will have the number of columns matching
    /// the element with the most nodes, and those elements
    /// with less nodes will have a zero in the element matrix, 
    /// indicating "no further nodes in element"
    /// <para>
    /// It basically converts the element table of form 
    /// <code>int[][]</code> to an element matrix of form
    /// <code>int[,]</code>.
    /// </para>
    /// </summary>
    /// <param name="elementTable">elementTable</param>
    /// <returns>Element matrix</returns>
    public static int[,] ToElementMatrix(int[][] elementTable)
    {
     
      // Find maximum number of nodes for a single element
      int maxNodes = 0;
      foreach (int[] elmtNodes in elementTable)
      {
        int noNodes = elmtNodes.Length;
        if (noNodes > maxNodes)
          maxNodes = noNodes;
      }

      // Create element table in matrix version. The matrix is automatically 
      // initialized with zero values, which is what is required for specifying "no-more-nodes"
      int[,] elementMatrix = new int[elementTable.Length, maxNodes];
      for (int i = 0; i < elementTable.Length; i++)
      {
        int[] elmtNodes = elementTable[i];
        for (int j = 0; j < elmtNodes.Length; j++)
        {
          elementMatrix[i, j] = elmtNodes[j];
        }
      }

      return elementMatrix;
    }

    /// <summary>
    /// Convert the element matrix from MATLAB to 
    /// a dfsu element table, i.e. from a int[,] to a int[][]. 
    /// In case of mixed elements (triangles/quadrilaterals)
    /// the elements will not have the same number of nodes.
    /// The input will have the number of columns matching
    /// the element with the most nodes, and those elements
    /// with less nodes will have a zero in the element matrix, 
    /// indicating "no further nodes in element"
    /// <para>
    /// It basically converts the element matrix of form 
    /// <code>int[,]</code> to an element table of form
    /// <code>int[][]</code>.
    /// </para>
    /// </summary>
    /// <param name="elementMatrix">elementMatrix</param>
    /// <returns>Element table</returns>
    public static int[][] ToElementTable(int[,] elementMatrix)
    {
      int numElmts = elementMatrix.GetLength(0);
      int maxNodes = elementMatrix.GetLength(1);
      int[][] elementTable = new int[numElmts][];

      for (int i = 0; i < numElmts; i++)
      {
        // Count the number of nodes in this element
        int noNodes = 0;
        for (int j = 0; j < maxNodes; j++)
        {
          if (elementMatrix[i, j] == 0)
            break;
          noNodes++;
        }

        // there are noNodes nodes in this element, copy them
        // to int[]
        int[] elmtNodes = new int[noNodes];
        for (int j = 0; j < noNodes; j++)
        {
          elmtNodes[j] = elementMatrix[i, j];
        }

        elementTable[i] = elmtNodes;
      }

      return elementTable;
    }

  }
}
