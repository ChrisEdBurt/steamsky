--  This package has been generated automatically by GNATtest.
--  You are allowed to add your code to the bodies of test routines.
--  Such changes will be kept during further regeneration of this file.
--  All code placed outside of test routine bodies will be lost. The
--  code intended to set up and tear down the test environment should be
--  placed into Statistics.Test_Data.

with AUnit.Assertions; use AUnit.Assertions;
with System.Assertions;

--  begin read only
--  id:2.2/00/
--
--  This section can be used to add with clauses if necessary.
--
--  end read only

--  begin read only
--  end read only
package body Statistics.Test_Data.Tests is

--  begin read only
--  id:2.2/01/
--
--  This section can be used to add global variables and other elements.
--
--  end read only

--  begin read only
--  end read only
--  begin read only
   procedure Wrap_Test_UpdateDestroyedShips_708ec3_001497 (ShipName: Unbounded_String) 
   is
   begin
      begin
         pragma Assert
           (ShipName /= Null_Unbounded_String);
         null;
      exception
         when System.Assertions.Assert_Failure =>
            AUnit.Assertions.Assert
              (False,
               "req_sloc(statistics.ads:0):Test_UpdateDestroyedShips test requirement violated");
      end;
      GNATtest_Generated.GNATtest_Standard.Statistics.UpdateDestroyedShips (ShipName);
      begin
         pragma Assert
           (True);
         null;
      exception
         when System.Assertions.Assert_Failure =>
            AUnit.Assertions.Assert
              (False,
               "ens_sloc(statistics.ads:0:):Test_UpdateDestroyedShips test commitment violated");
      end;
   end Wrap_Test_UpdateDestroyedShips_708ec3_001497;
--  end read only

--  begin read only
   procedure Test_UpdateDestroyedShips_test_updatedestroyedships (Gnattest_T : in out Test);
   procedure Test_UpdateDestroyedShips_708ec3_001497 (Gnattest_T : in out Test) renames Test_UpdateDestroyedShips_test_updatedestroyedships;
--  id:2.2/708ec30adf523180/UpdateDestroyedShips/1/0/test_updatedestroyedships/
   procedure Test_UpdateDestroyedShips_test_updatedestroyedships (Gnattest_T : in out Test) is
   procedure UpdateDestroyedShips (ShipName: Unbounded_String) renames Wrap_Test_UpdateDestroyedShips_708ec3_001497;
--  end read only

      pragma Unreferenced (Gnattest_T);

   begin

      UpdateDestroyedShips(To_Unbounded_String("Tiny pirates ship"));
      Assert(Gamestats.DestroyedShips.Length = 1, "Failed to add ship to destroyed ships list.");
      UpdateDestroyedShips(To_Unbounded_String("Sfdsfdsf"));
      Assert(Gamestats.DestroyedShips.Length = 1, "Failed to not add non existing ship to destroyed ships list.");

--  begin read only
   end Test_UpdateDestroyedShips_test_updatedestroyedships;
--  end read only

--  begin read only
   procedure Wrap_Test_ClearGameStats_97edec_31f9dd
   is
   begin
      GNATtest_Generated.GNATtest_Standard.Statistics.ClearGameStats;
   end Wrap_Test_ClearGameStats_97edec_31f9dd;
--  end read only

--  begin read only
   procedure Test_ClearGameStats_test_cleargamestats (Gnattest_T : in out Test);
   procedure Test_ClearGameStats_97edec_31f9dd (Gnattest_T : in out Test) renames Test_ClearGameStats_test_cleargamestats;
--  id:2.2/97edec1268a24200/ClearGameStats/1/0/test_cleargamestats/
   procedure Test_ClearGameStats_test_cleargamestats (Gnattest_T : in out Test) is
   procedure ClearGameStats renames Wrap_Test_ClearGameStats_97edec_31f9dd;
--  end read only

      pragma Unreferenced (Gnattest_T);

   begin

      ClearGameStats;
      Assert(Gamestats.DestroyedShips.Length = 0, "Failed to clear game statistics.");

--  begin read only
   end Test_ClearGameStats_test_cleargamestats;
--  end read only

--  begin read only
   procedure Wrap_Test_UpdateFinishedGoals_9c0615_51796d (Index: Unbounded_String) 
   is
   begin
      begin
         pragma Assert
           (Index /= Null_Unbounded_String);
         null;
      exception
         when System.Assertions.Assert_Failure =>
            AUnit.Assertions.Assert
              (False,
               "req_sloc(statistics.ads:0):Test_UpdateFinishedGoals test requirement violated");
      end;
      GNATtest_Generated.GNATtest_Standard.Statistics.UpdateFinishedGoals (Index);
      begin
         pragma Assert
           (True);
         null;
      exception
         when System.Assertions.Assert_Failure =>
            AUnit.Assertions.Assert
              (False,
               "ens_sloc(statistics.ads:0:):Test_UpdateFinishedGoals test commitment violated");
      end;
   end Wrap_Test_UpdateFinishedGoals_9c0615_51796d;
--  end read only

--  begin read only
   procedure Test_UpdateFinishedGoals_test_updatefinishedgoals (Gnattest_T : in out Test);
   procedure Test_UpdateFinishedGoals_9c0615_51796d (Gnattest_T : in out Test) renames Test_UpdateFinishedGoals_test_updatefinishedgoals;
--  id:2.2/9c061556f3d17076/UpdateFinishedGoals/1/0/test_updatefinishedgoals/
   procedure Test_UpdateFinishedGoals_test_updatefinishedgoals (Gnattest_T : in out Test) is
   procedure UpdateFinishedGoals (Index: Unbounded_String) renames Wrap_Test_UpdateFinishedGoals_9c0615_51796d;
--  end read only

      pragma Unreferenced (Gnattest_T);

   begin

      UpdateFinishedGoals(To_Unbounded_String("1"));
      Assert(Gamestats.FinishedGoals.Length = 1, "Failed to add goal to finished goals list.");
      UpdateFinishedGoals(To_Unbounded_String("Sfdsfdsf"));
      Assert(Gamestats.FinishedGoals.Length = 1, "Failed to not add non goal to finished goals list.");

--  begin read only
   end Test_UpdateFinishedGoals_test_updatefinishedgoals;
--  end read only

--  begin read only
--  id:2.2/02/
--
--  This section can be used to add elaboration code for the global state.
--
begin
--  end read only
   null;
--  begin read only
--  end read only
end Statistics.Test_Data.Tests;
