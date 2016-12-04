--    Copyright 2016 Bartek thindil Jasicki
--    
--    This file is part of Steam Sky.
--
--    Steam Sky is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Steam Sky is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with Steam Sky.  If not, see <http://www.gnu.org/licenses/>.

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Directories; use Ada.Directories;
with UserInterface; use UserInterface;
with Messages; use Messages;
with Ships; use Ships;
with Crew; use Crew;
with Items; use Items;

package body Crafts is

    function LoadRecipes return Boolean is
        RecipesFile : File_Type;
        RawData, FieldName, Value : Unbounded_String;
        EqualIndex, StartIndex, EndIndex, Amount : Natural;
        TempRecord : Craft_Data;
        TempMaterials : UnboundedString_Container.Vector;
        TempAmount : Positive_Container.Vector;
    begin
        if Recipes_List.Length > 0 then
            return True;
        end if;
        if not Exists("data/recipes.dat") then
            return False;
        end if;
        TempRecord := (MaterialTypes => TempMaterials, MaterialAmounts => TempAmount,
            ResultIndex => 1, ResultAmount => 10000, Workplace => ALCHEMY_LAB,
            Skill => 1, Time => 15);
        Open(RecipesFile, In_File, "data/recipes.dat");
        while not End_Of_File(RecipesFile) loop
            RawData := To_Unbounded_String(Get_Line(RecipesFile));
            if Element(RawData, 1) /= '[' then
                EqualIndex := Index(RawData, "=");
                FieldName := Head(RawData, EqualIndex - 2);
                Value := Tail(RawData, (Length(RawData) - EqualIndex - 1));
                if FieldName = To_Unbounded_String("Material") then
                    StartIndex := 1;
                    Amount := Ada.Strings.Unbounded.Count(Value, ", ") + 1;
                    for I in 1..Amount loop
                        EndIndex := Index(Value, ", ", StartIndex);
                        if EndIndex = 0 then
                            EndIndex := Length(Value) + 1;
                        end if;
                        TempRecord.MaterialTypes.Append(New_Item => To_Unbounded_String(Slice(Value, StartIndex, EndIndex - 1)));
                        StartIndex := EndIndex + 2;
                    end loop;
                elsif FieldName = To_Unbounded_String("Amount") then
                    StartIndex := 1;
                    Amount := Ada.Strings.Unbounded.Count(Value, ", ") + 1;
                    for I in 1..Amount loop
                        EndIndex := Index(Value, ", ", StartIndex);
                        if EndIndex = 0 then
                            EndIndex := Length(Value) + 1;
                        end if;
                        TempRecord.MaterialAmounts.Append(New_Item => Integer'Value(Slice(Value, StartIndex, EndIndex - 1)));
                        StartIndex := EndIndex + 2;
                    end loop;
                elsif FieldName = To_Unbounded_String("Result") then
                    TempRecord.ResultIndex := Integer'Value(To_String(Value));
                elsif FieldName = To_Unbounded_String("Crafted") then
                    TempRecord.ResultAmount := Integer'Value(To_String(Value));
                elsif FieldName = To_Unbounded_String("Workplace") then
                    TempRecord.Workplace := ModuleType'Value(To_String(Value));
                elsif FieldName = To_Unbounded_String("Skill") then
                    for I in Skills_Names.First_Index..Skills_Names.Last_Index loop
                        if Value = To_String(Skills_Names.Element(I)) then
                            TempRecord.Skill := I;
                            exit;
                        end if;
                    end loop;
                elsif FieldName = To_Unbounded_String("Time") then
                    TempRecord.Time := Integer'Value(To_String(Value));
                end if;
            elsif TempRecord.ResultAmount < 10000 then
                Recipes_List.Append(New_Item => TempRecord);
                TempRecord := (MaterialTypes => TempMaterials, MaterialAmounts => TempAmount,
                    ResultIndex => 1, ResultAmount => 10000, Workplace => ALCHEMY_LAB, 
                    Skill => 1, Time => 15);
            end if;
        end loop;
        Close(RecipesFile);
        return True;
    end LoadRecipes;

    procedure SetRecipe(RecipeIndex, ModuleIndex : Positive) is
        Recipe : constant Craft_Data := Recipes_List.Element(RecipeIndex);
        SpaceNeeded : Integer := 0;
        MaterialIndexes : array (Recipe.MaterialTypes.First_Index..Recipe.MaterialTypes.Last_Index) of
            Natural := (others => 0);
    begin
        -- Check for materials
        for I in PlayerShip.Cargo.First_Index..PlayerShip.Cargo.Last_Index loop
            for J in Recipe.MaterialTypes.First_Index..Recipe.MaterialTypes.Last_Index loop
                if Items_List.Element(PlayerShip.Cargo.Element(I).ProtoIndex).IType = Recipe.MaterialTypes(J) and
                    PlayerShip.Cargo.Element(I).Amount >= Recipe.MaterialAmounts(J) then
                    MaterialIndexes(J) := I;
                end if;
            end loop;
        end loop;
        for I in MaterialIndexes'Range loop
            if MaterialIndexes(I) = 0 then
                ShowDialog("You don't have enough materials to start manufacturing " & 
                To_String(Items_List.Element(Recipe.ResultIndex).Name) & ".");
                return;
            end if;
        end loop;
        for I in MaterialIndexes'Range loop
            SpaceNeeded := SpaceNeeded + Items_List.Element(MaterialIndexes(I)).Weight * Recipe.MaterialAmounts.Element(I);
        end loop;
        if FreeCargo(SpaceNeeded - (Items_List.Element(Recipe.ResultIndex).Weight * Recipe.ResultAmount)) < 0 then
            ShowDialog("You don't have that much free space in your ship cargo.");
            return;
        end if;
        UpdateModule(PlayerShip, ModuleIndex, "Current_Value", Positive'Image(RecipeIndex));
        UpdateModule(PlayerShip, ModuleIndex, "Max_Value", Positive'Image(Recipe.Time));
        AddMessage(To_String(Items_List.Element(Recipe.ResultIndex).Name) & " was set as manufacturing order in " & 
            To_String(PlayerShip.Modules.Element(ModuleIndex).Name) & ".", CraftMessage);
    end SetRecipe;

    procedure Manufacturing(Minutes : Positive) is
        CrafterIndex, Amount, ResultAmount, CraftedAmount, GainedExp : Natural := 0;
        Recipe : Craft_Data;
        MaterialIndexes : array(1..10) of Natural := (others => 0);
        WorkTime, CurrentMinutes, RecipeTime : Integer;
        type DamageFactor is digits 2 range 0.0..1.0;
        Damage : DamageFactor := 0.0;
        subtype Workplaces is ModuleType range ALCHEMY_LAB..GREENHOUSE;
        procedure UpdateMember(Member : in out Member_Data) is
        begin
            Member.OrderTime := WorkTime;
        end UpdateMember;
    begin
        for L in PlayerShip.Modules.First_Index..PlayerShip.Modules.Last_Index loop
            if PlayerShip.Modules.Element(L).Owner > 0 and (Modules_List.Element(PlayerShip.Modules.Element(L).ProtoIndex).MType 
                in Workplaces) and PlayerShip.Modules.Element(L).Current_Value > 0
            then
                CrafterIndex := PlayerShip.Modules.Element(L).Owner;
                if PlayerShip.Crew.Element(CrafterIndex).Order = Craft then
                    CurrentMinutes := Minutes;
                    RecipeTime := PlayerShip.Modules.Element(L).Max_Value;
                    Recipe := Recipes_List.Element(PlayerShip.Modules.Element(L).Current_Value);
                    WorkTime := PlayerShip.Crew.Element(CrafterIndex).OrderTime;
                    Craft_Loop:
                    while CurrentMinutes > 0 loop
                        if CurrentMinutes >= RecipeTime then
                            CurrentMinutes := CurrentMinutes - RecipeTime;
                            WorkTime := WorkTime - RecipeTime;
                            RecipeTime := Recipe.Time; 
                            MaterialIndexes := (others => 0);
                            for J in PlayerShip.Cargo.First_Index..PlayerShip.Cargo.Last_Index loop
                                for K in Recipe.MaterialTypes.First_Index..Recipe.MaterialTypes.Last_Index loop
                                    if Items_List.Element(PlayerShip.Cargo.Element(J).ProtoIndex).IType = Recipe.MaterialTypes(K) then
                                        MaterialIndexes(K) := J;
                                    end if;
                                end loop;
                            end loop;
                            for J in Recipe.MaterialTypes.First_Index..Recipe.MaterialTypes.Last_Index loop
                                if MaterialIndexes(J) = 0 then
                                    AddMessage("You don't have any crafting materials for manufacturing " & 
                                        To_String(Items_List.Element(Recipe.ResultIndex).Name) & ".", CraftMessage);
                                    GiveOrders(CrafterIndex, Rest);
                                    UpdateModule(PlayerShip, L, "Current_Value", "0");
                                    UpdateModule(PlayerShip, L, "Max_Value", Integer'Image(0 - PlayerShip.Modules.Element(L).Max_Value));
                                    exit Craft_Loop;
                                end if;
                            end loop;
                            Amount := 0;
                            for J in Recipe.MaterialTypes.First_Index..Recipe.MaterialTypes.Last_Index loop
                                Amount := Amount + Items_List.Element(PlayerShip.Cargo.Element(MaterialIndexes(J)).ProtoIndex).Weight * 
                                Recipe.MaterialAmounts.Element(J);
                            end loop;
                            ResultAmount := Recipe.ResultAmount + Integer(Float'Floor(Float(Recipe.ResultAmount) *
                                (Float(GetSkillLevel(CrafterIndex, Recipe.Skill)) / 100.0)));
                            Damage := 1.0 - DamageFactor(Float(PlayerShip.Modules.Element(L).Durability) / 
                                Float(PlayerShip.Modules.Element(L).MaxDurability));
                            ResultAmount := ResultAmount - Natural(Float(ResultAmount) * Float(Damage));
                            if ResultAmount = 0 then
                                ResultAmount := 1;
                            end if;
                            Amount := Amount - (Items_List.Element(Recipe.ResultIndex).Weight * ResultAmount);
                            if FreeCargo(Amount) < 0 then
                                AddMessage("You don't have free cargo space for manufacturing " & 
                                    To_String(Items_List.Element(Recipe.ResultIndex).Name) & ".", CraftMessage);
                                GiveOrders(CrafterIndex, Rest);
                                UpdateModule(PlayerShip, L, "Current_Value", "0");
                                UpdateModule(PlayerShip, L, "Max_Value", Integer'Image(0 - PlayerShip.Modules.Element(L).Max_Value));
                                exit Craft_Loop;
                            end if;
                            for J in Recipe.MaterialTypes.First_Index..Recipe.MaterialTypes.Last_Index loop
                                if PlayerShip.Cargo.Element(MaterialIndexes(J)).Amount < Recipe.MaterialAmounts.Element(J) then
                                    AddMessage("You don't have enough crafting materials for manufacturing " & 
                                        To_String(Items_List.Element(Recipe.ResultIndex).Name) & 
                                    ".", CraftMessage);
                                    GiveOrders(CrafterIndex, Rest);
                                    UpdateModule(PlayerShip, L, "Current_Value", "0");
                                    UpdateModule(PlayerShip, L, "Max_Value", Integer'Image(0 - PlayerShip.Modules.Element(L).Max_Value));
                                    exit Craft_Loop;
                                end if;
                            end loop;
                            CraftedAmount := CraftedAmount + ResultAmount;
                            for J in Recipe.MaterialTypes.First_Index..Recipe.MaterialTypes.Last_Index loop
                                Amount := Integer(PlayerShip.Cargo.Length);
                                UpdateCargo(PlayerShip, PlayerShip.Cargo.Element(MaterialIndexes(J)).ProtoIndex, (0 - Recipe.MaterialAmounts.Element(J)));
                                if Integer(PlayerShip.Cargo.Length) /= Amount then
                                    MaterialIndexes := (others => 0);
                                    for L in PlayerShip.Cargo.First_Index..PlayerShip.Cargo.Last_Index loop
                                        for K in Recipe.MaterialTypes.First_Index..Recipe.MaterialTypes.Last_Index loop
                                            if Items_List.Element(PlayerShip.Cargo.Element(L).ProtoIndex).IType = Recipe.MaterialTypes(K) then
                                                MaterialIndexes(K) := L;
                                            end if;
                                        end loop;
                                    end loop;
                                end if;
                            end loop;
                            Amount := 0;
                            UpdateCargo(PlayerShip, Recipes_List.Element(PlayerShip.Modules.Element(L).Current_Value).ResultIndex, ResultAmount);
                        else
                            RecipeTime := RecipeTime - CurrentMinutes;
                            WorkTime := WorkTime - CurrentMinutes;
                            CurrentMinutes := 0;
                        end if;
                    end loop Craft_Loop;
                    UpdateModule(PlayerShip, L, "Max_Value", Positive'Image((0 - PlayerShip.Modules.Element(L).Max_Value) + RecipeTime));
                    if CraftedAmount > 0 then
                        AddMessage(To_String(PlayerShip.Crew.Element(CrafterIndex).Name) & " was manufactured" & 
                            Integer'Image(CraftedAmount) &  " " & To_String(Items_List.Element(Recipe.ResultIndex).Name) & 
                            ".", CraftMessage);
                    end if;
                    CraftedAmount := 0;
                    if PlayerShip.Crew.Element(CrafterIndex).Order = Craft then
                        while WorkTime <= 0 loop
                            GainedExp := GainedExp + 1;
                            WorkTime := WorkTime + 15;
                        end loop;
                        if GainedExp > 0 then
                            GainExp(GainedExp, Recipe.Skill, CrafterIndex);
                        end if;
                        PlayerShip.Crew.Update_Element(Index => CrafterIndex, Process => UpdateMember'Access);
                    end if;
                end if;
            end if;
        end loop;
    end Manufacturing;

end Crafts;
