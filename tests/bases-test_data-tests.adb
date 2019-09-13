--  This package has been generated automatically by GNATtest.
--  You are allowed to add your code to the bodies of test routines.
--  Such changes will be kept during further regeneration of this file.
--  All code placed outside of test routine bodies will be lost. The
--  code intended to set up and tear down the test environment should be
--  placed into Bases.Test_Data.

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
package body Bases.Test_Data.Tests is

--  begin read only
--  id:2.2/01/
--
--  This section can be used to add global variables and other elements.
--
--  end read only

--  begin read only
--  end read only
--  begin read only
   procedure Wrap_Test_GainRep_6338e6_901e58 (BaseIndex: BasesRange; Points: Integer) 
   is
   begin
      GNATtest_Generated.GNATtest_Standard.Bases.GainRep (BaseIndex, Points);
   end Wrap_Test_GainRep_6338e6_901e58;
--  end read only

--  begin read only
   procedure Test_GainRep_test_gainrep (Gnattest_T : in out Test);
   procedure Test_GainRep_6338e6_901e58 (Gnattest_T : in out Test) renames Test_GainRep_test_gainrep;
--  id:2.2/6338e6483a422dde/GainRep/1/0/test_gainrep/
   procedure Test_GainRep_test_gainrep (Gnattest_T : in out Test) is
   procedure GainRep (BaseIndex: BasesRange; Points: Integer) renames Wrap_Test_GainRep_6338e6_901e58;
--  end read only

      pragma Unreferenced (Gnattest_T);

   begin

      SkyBases(1).Reputation := (1, 1);
      GainRep(1, 1);
      Assert(SkyBases(1).Reputation(2) = 2, "Failed to gain reputation in base.");
      GainRep(1, -1);
      Assert(SkyBases(1).Reputation(2) = 1, "Failed to lose reputation in base.");

--  begin read only
   end Test_GainRep_test_gainrep;
--  end read only

--  begin read only
   procedure Wrap_Test_CountPrice_173272_bef05e (Price: in out Natural; TraderIndex: Crew_Container.Extended_Index; Reduce: Boolean := True) 
   is
   begin
      begin
         pragma Assert
           (TraderIndex <= PlayerShip.Crew.Last_Index);
         null;
      exception
         when System.Assertions.Assert_Failure =>
            AUnit.Assertions.Assert
              (False,
               "req_sloc(bases.ads:0):Test_CountPrice test requirement violated");
      end;
      GNATtest_Generated.GNATtest_Standard.Bases.CountPrice (Price, TraderIndex, Reduce);
      begin
         pragma Assert
           (True);
         null;
      exception
         when System.Assertions.Assert_Failure =>
            AUnit.Assertions.Assert
              (False,
               "ens_sloc(bases.ads:0:):Test_CountPrice test commitment violated");
      end;
   end Wrap_Test_CountPrice_173272_bef05e;
--  end read only

--  begin read only
   procedure Test_CountPrice_test_countprice (Gnattest_T : in out Test);
   procedure Test_CountPrice_173272_bef05e (Gnattest_T : in out Test) renames Test_CountPrice_test_countprice;
--  id:2.2/17327298eafedc9a/CountPrice/1/0/test_countprice/
   procedure Test_CountPrice_test_countprice (Gnattest_T : in out Test) is
   procedure CountPrice (Price: in out Natural; TraderIndex: Crew_Container.Extended_Index; Reduce: Boolean := True) renames Wrap_Test_CountPrice_173272_bef05e;
--  end read only

      pragma Unreferenced (Gnattest_T);
      Price: Positive := 100;

   begin

      CountPrice(Price, 1, False);
      Assert(Price > 100, "Failed to raise price in base.");
      Price := 100;
      CountPrice(Price, 1);
      Assert(Price < 100, "Failed to reduce price in base.");

--  begin read only
   end Test_CountPrice_test_countprice;
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
end Bases.Test_Data.Tests;