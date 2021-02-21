using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using System.Threading;
using System.Data;
using System.IO;
using System.Globalization;

using cAlgo;
using cAlgo.API;
using cAlgo.API.Indicators;
using cAlgo.API.Internals;
using cAlgo.API.Collections;
using cAlgo.API.Requests;
using cAlgo.Indicators;

namespace cAlgo
{
    class DataOps
    {
        //props
        internal PositionsDataTableOps pdto; //positions data table and related methods
        internal PositionsDataFileOps pdfo;  //positions data file and related methods, depends on PositionsDataTableOps obj.
        internal MultiStage3 cBot { get; set; }

        //c'tor
        public DataOps(MultiStage3 cBot)
        {
            this.cBot = cBot;
            pdto = new PositionsDataTableOps(this); //dependency for dfo
            pdfo = new PositionsDataFileOps(this, pdto);
        }

        //methods
        internal void Reconcile()
        {//reconciles positions data file to positions data table
            
            //temp data table from open positions
            DataTable openPosDt = pdto.GetOpenPositionsTable();
            
            //get refrence to current positions table to reconcile the tables
            if (pdto.pdt != null) //there should be a pos. data table in memory from c'tor
            {
                //get comparison lists dictionary
                var comparisonDic1 = pdto.CompareDataTables(openPosDt, pdto.pdt);
                
                //get common positions list
                List<string> dicPosLst1;
                comparisonDic1.TryGetValue("commonPosIDs", out dicPosLst1);
                
                //get assigned exits from current table into newly formed openPos table
                pdto.CopyExitSecondToFirstTable(openPosDt, pdto.pdt, dicPosLst1);
                
                //investigate any trades that are in current table, but not in openPos table against history
                comparisonDic1.TryGetValue("inSecondNotInFirst", out dicPosLst1);
                //might want to check bool return
                //is out going to properly overwrite prev. values in dicPosLst?
                InvestigateHist(dicPosLst1);
            }
            //set updated table as positions table
            pdto.pdt = openPosDt;
            
            //get data table from file
            DataTable dtFromFile = pdto.GetDataTableFromFile(pdfo.filePath);
            
            //get comparison lists dictionary
            var comparisonDic = pdto.CompareDataTables(pdto.pdt, dtFromFile);
            
            //get common positions list
            List<string> dicPosLst;
            comparisonDic.TryGetValue("commonPosIDs", out dicPosLst);

            //get assigned exits from file table into Pos table
            pdto.CopyExitSecondToFirstTable(pdto.pdt, dtFromFile, dicPosLst);
            
            //investigate any trades that are in file table, but not in Pos table against history
            comparisonDic.TryGetValue("inSecondNotInFirst", out dicPosLst);
            //might want to check bool return
            //is out going to properly overwrite prev. values in dicPosLst?
            InvestigateHist(dicPosLst);
            //write positions table to file, back up file, and clean out old (24 hrs.) files
            pdfo.DataFileProcessor(pdto.pdt);
        }//Reconcile()

        private void InvestigateHist(List<string> posLst)
        {//searches historical trades, and sends alert on findings
            foreach (var posID in posLst)
            {
                //if (posID == "Pos_ID") continue; //do not investigate column heading
                var pos = cBot.History.FirstOrDefault(p=>p.PositionId.ToString()== posID);
                //Where(p => p.PositionId.ToString() == posID)
                //YourCollection.DefaultIfEmpty(YourDefault).First()
                if (pos != null)
                {
                    var msg = string.Format("InvestigateHist: {0} located in history. Net:{1} Comment:{2}", 
                        pos.PositionId, pos.NetProfit, pos.Comment);
                    cBot.SendAlert(msg);
                }
                else
                {
                    var msg = string.Format("InvestigateHist: Position {0} not found in history", posID);
                    cBot.SendAlert(msg);
                }
            }//foreach
            
        }//InvestigateHist

    }//DataOps class

}//namespace

