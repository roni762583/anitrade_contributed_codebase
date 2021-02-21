using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using System.Threading;
using System.Data;
using System.IO;
using System.Globalization;

////using cAlgo;
using cAlgo.API;
//using cAlgo.API.Indicators;
//using cAlgo.API.Internals;
//using cAlgo.API.Collections;
//using cAlgo.API.Requests;
//using cAlgo.Indicators;

namespace cAlgo
{
    class PositionsDataTableOps
    {//this class encapsulates the positions data table and methods related to creation and management of table

        //props
        internal DataTable pdt { get; set; } //positions data table
        internal DataOps dataOps { get; set; } //ref. to associated cBot

        //c'tor
        public PositionsDataTableOps(DataOps dataOps)
        {
            this.dataOps = dataOps;
            //build positions data table with schema
            pdt = GetOpenPositionsTable();
        }

        //Methods
        internal DataTable GetOpenPositionsTable()
        {//Gets data table populated with all currently open positions
            DataTable pt = BuildDataTableSchema();
            PopulatePositionsDataTable(pt);
            return pt;
        }//CompilePositionsDataTableFromOpenPositions

        internal DataTable BuildDataTableSchema()
        {//creates and returns data table with schema for positions
            DataTable dt = new DataTable();
            //name
            dt.TableName = "positionsTable";
            //columns
            dt.Columns.Add("Pos_ID", typeof(string));
            dt.Columns.Add("EntryStrategy", typeof(string));
            dt.Columns.Add("AssignedExitStrategy", typeof(string));
            dt.Columns.Add("Comments", typeof(string));
            //set primary key
            dt.PrimaryKey = new DataColumn[] { dt.Columns["Pos_ID"] };
            dt.AcceptChanges();
            return dt;
        }

        internal string GetPositionExit(string posID, DataTable pdt)
        {
            return (string)pdt.Rows.Find(posID)["AssignedExitStrategy"];
        }

        internal void PopulatePositionsDataTable(DataTable pt)
        {//populates data table with all live/open positions
            foreach (var pos in dataOps.cBot.Positions)
            {
                DataRow row = pt.NewRow();
                row["Pos_ID"] = pos.Id.ToString();
                row["EntryStrategy"] = pos.Label;
                row["AssignedExitStrategy"] = "";
                row["Comments"] = pos.Comment;
                pt.Rows.Add(row);
                pt.AcceptChanges();
            }
        }//PopulatePositionsDataTable()
        
        internal DataTable GetDataTableFromFile(string filePath)
        {//builds and returns DataTable from positions data file (filePath is full path)

            //what if data file is non-existant??

            //clones structure of positionsTable
            DataTable dt = this.pdt.Clone();
            //loop over lines in data file, parse and build data row
            foreach (string line in File.ReadLines(filePath))
            {
                var parsedLn = line.Split(',');
                //creates new dataRow object with schema from table
                DataRow row = dt.NewRow();
                row["Pos_ID"] = parsedLn[0];//first column
                row["EntryStrategy"] = parsedLn[1];//second column
                row["AssignedExitStrategy"] = parsedLn[2];
                row["Comments"] = parsedLn[3];
                dt.Rows.Add(row);
                dt.AcceptChanges();
            }
            dt.AcceptChanges();//necessary?
            return dt;
        }//GetDataTableFromFile()

        //method compares two positions data tables and returns dictionary of lists:
        //livePosIDs, filePosIDs, inFileNotLive, liveNotInFile, commonPosIDs
        internal Dictionary<string, List<string>> CompareDataTables(DataTable firstDT, DataTable secondDT)
        {
            //declare dictionary of comparison lists to return
            Dictionary<string, List<string>> dic = new Dictionary<string, List<string>>();

            //list of all first Data table position ID's
            List<string> firstDtPosId = GetPosIDsFromTable(firstDT);
            dic.Add("firstDtPosId", firstDtPosId);
            
            //list of all second Data table position ID's
            List<string> secondDtPosId = GetPosIDsFromTable(secondDT);
            dic.Add("secondDtPosId", secondDtPosId);

            //list of position ID's found in second data table, but not in first
            List<string> inSecondNotInFirst = secondDtPosId.Except(firstDtPosId).ToList();
            dic.Add("inSecondNotInFirst", inSecondNotInFirst);

            //list of position ID's found in first data table, but not in second 
            List<string> inFirstNotInSecond = firstDtPosId.Except(secondDtPosId).ToList();
            dic.Add("inFirstNotInSecond", inFirstNotInSecond);

            //list of position ID's common to both live and file collections
            List<string> commonPosIDs = firstDtPosId.Except(inFirstNotInSecond).ToList();
            dic.Add("commonPosIDs", commonPosIDs);

            return dic;
        }

        internal List<string> GetPosIDsFromTable()
        {//returns list of all position ID's found in table
            List<string> posIdList = new List<string>();
            foreach (DataRow row in pdt.Rows)
            {
                if (row["Pos_ID"].ToString() == "Pos_ID") continue; //do not add column heading
                posIdList.Add(row["Pos_ID"].ToString());
            }
            return posIdList;
        }//GetPosIDsFromTable()


        internal List<string> GetPosIDsFromTable(string exit)
        {//returns list of all position ID's for exit in table
            List<string> posIdList = new List<string>();
            foreach (DataRow row in pdt.Rows)
            {
                if (row["Pos_ID"].ToString() == "Pos_ID") continue; //do not add column heading
                
                if (row["AssignedExitStrategy"].ToString() == exit)
                {//if assigned strategy matched exit, add to returned list
                    posIdList.Add(row["Pos_ID"].ToString());
                }
            }
            return posIdList;
        }//GetPosIDsFromTable()

        internal List<Position> GetPosRefListFromPosTableByAssignedExit(string exit)
        {//returns a position obj ref. list for all pos. in table assigned to exit strategy
            List<Position> posRefList = new List<Position>();
            var psns = dataOps.cBot.Positions;
            foreach (DataRow row in pdt.Rows)
            {
                if (row["Pos_ID"].ToString() == "Pos_ID") continue; //do not add column heading

                if (row["AssignedExitStrategy"].ToString() == exit)
                {//if assigned strategy matched exit, add to returned list
                    var rslt = psns.Where(p => p.Id.ToString() == row["Pos_ID"].ToString()).FirstOrDefault();
                    if (rslt != null) posRefList.Add(rslt);
                    else
                    {
                        string msg = "GetPosRefListFromPosTableByAssignedExit() could not locate posID: " +
                            row["Pos_ID"].ToString() + "in live positions";
                        dataOps.cBot.SendAlert(msg);
                    }
                }
            }
            return posRefList;
        }//GetPosRefListFromPosTableByAssignedExit()

        internal List<string> GetActiveExitsFromTable(DataTable table)
        {//returns list of unique assigned exits found in table
            HashSet<string> hs = new HashSet<string>();
            //List<string> extList = new List<string>();
            foreach (DataRow row in table.Rows)
            {
                if (row["AssignedExitStrategy"].ToString() == "AssignedExitStrategy") continue; //do not add column heading
                hs.Add(row["AssignedExitStrategy"].ToString());
                //extList.Add(row["AssignedExitStrategy"].ToString());
            }
            return hs.ToList();
        }//GetActiveExitsFromTable()

        

        internal void CopyExitSecondToFirstTable(DataTable first, DataTable second, List<string> commonPos)
        {
            //get assigned exits for common positions as found in current table 
            foreach (string posID in commonPos)
            {
                //get assigned exit from current table, and write it to freshly constructed openPosDt
                string exit = GetPositionExit(posID, second);
                first.Rows.Find(posID)["AssignedExitStrategy"] = exit;
            }
        }//CopyExitSecondToFirstTable()

    }//class

}//namespace
