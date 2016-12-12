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

with Terminal_Interface.Curses.Menus; use Terminal_Interface.Curses.Menus;
with UserInterface; use UserInterface;
with Ships; use Ships;
with Messages; use Messages;
with Bases; use Bases;
with Maps; use Maps;
with ShipModules; use ShipModules;
with Items; use Items;

package body Crew.UI is

    CrewMenu, OrdersMenu : Menu;
    MenuWindow, MenuWindow2 : Window;
    MemberIndex : Positive := 1;

    procedure ShowMemberInfo is
        InfoWindow : Window;
        Member : constant Member_Data := PlayerShip.Crew.Element(MemberIndex);
        CurrentLine : Line_Position := 1;
        Health, Tired, Hungry, Thirsty, SkillLevel, OrderName : Unbounded_String := Null_Unbounded_String;
    begin
        if Member.Health < 100 and Member.Health > 80 then
            Health := To_Unbounded_String("Slightly wounded");
        elsif Member.Health < 81 and Member.Health > 50 then
            Health := To_Unbounded_String("Wounded");
        elsif Member.Health < 51 then
            Health := To_Unbounded_String("Heavily Wounded");
        end if;
        if Member.Tired > 20 and Member.Tired < 41 then
            Tired := To_Unbounded_String("Bit tired");
        elsif Member.Tired > 40 and Member.Tired < 81 then
            Tired := To_Unbounded_String("Tired");
        elsif Member.Tired > 80 and Member.Tired < 100 then
            Tired := To_Unbounded_String("Very tired");
        elsif Member.Tired = 100 then
            Tired := To_Unbounded_String("Unconscious");
        end if;
        if Member.Thirst > 20 and Member.Thirst < 41 then
            Thirsty := To_Unbounded_String("Bit thirsty");
        elsif Member.Thirst > 40 and Member.Thirst < 81 then
            Thirsty := To_Unbounded_String("Thirsty");
        elsif Member.Thirst > 80 and Member.Thirst < 100 then
            Thirsty := To_Unbounded_String("Very thirsty");
        elsif Member.Thirst = 100 then
            Thirsty := To_Unbounded_String("Dehydrated");
        end if;
        if Member.Hunger > 20 and Member.Hunger < 41 then
            Hungry := To_Unbounded_String("Bit hungry");
        elsif Member.Hunger > 40 and Member.Hunger < 81 then
            Hungry := To_Unbounded_String("Hungry");
        elsif Member.Hunger > 80 and Member.Hunger < 100 then
            Hungry := To_Unbounded_String("Very hungry");
        elsif Member.Hunger = 100 then
            Hungry := To_Unbounded_String("Starving");
        end if;
        InfoWindow := Create((Lines - 5), (Columns / 2), 3, (Columns / 2));
        if Member.Gender = 'M' then
            Add(Win => InfoWindow, Str => "Male");
        else
            Add(Win => InfoWindow, Str => "Female");
        end if;
        if Health /= Null_Unbounded_String then
            Move_Cursor(Win => InfoWindow, Line => CurrentLine, Column => 0);
            Add(Win => InfoWindow, Str => To_String(Health));
            CurrentLine := CurrentLine + 1;
        end if;
        if Tired /= Null_Unbounded_String then
            Move_Cursor(Win => InfoWindow, Line => CurrentLine, Column => 0);
            Add(Win => InfoWindow, Str => To_String(Tired));
            CurrentLine := CurrentLine + 1;
        end if;
        if Thirsty /= Null_Unbounded_String then
            Move_Cursor(Win => InfoWindow, Line => CurrentLine, Column => 0);
            Add(Win => InfoWindow, Str => To_String(Thirsty));
            CurrentLine := CurrentLine + 1;
        end if;
        if Hungry /= Null_Unbounded_String then
            Move_Cursor(Win => InfoWindow, Line => CurrentLine, Column => 0);
            Add(Win => InfoWindow, Str => To_String(Hungry));
            CurrentLine := CurrentLine + 1;
        end if;
        CurrentLine := CurrentLine + 1;
        for I in Member.Skills.First_Index..Member.Skills.Last_Index loop
            case Member.Skills.Element(I)(2) is
                when 1..10 =>
                    SkillLevel := To_Unbounded_String("Beginner");
                when 11..20 =>
                    SkillLevel := To_Unbounded_String("Novice");
                when 21..30 =>
                    SkillLevel := To_Unbounded_String("Apprentice");
                when 31..40 =>
                    SkillLevel := To_Unbounded_String("Practitioner");
                when 41..50 =>
                    SkillLevel := To_Unbounded_String("Competent");
                when 51..60 =>
                    SkillLevel := To_Unbounded_String("Respected");
                when 61..70 =>
                    SkillLevel := To_Unbounded_String("Renowned");
                when 71..80 =>
                    SkillLevel := To_Unbounded_String("Master");
                when 81..90 =>
                    SkillLevel := To_Unbounded_String("Grand-Master");
                when 91..99 =>
                    SkillLevel := To_Unbounded_String("Legendary");
                when others =>
                    SkillLevel := To_Unbounded_String("Ultimate");
            end case;
            Move_Cursor(Win => InfoWindow, Line => CurrentLine, Column => 0);
            Add(Win => InfoWindow, Str => To_String(Skills_Names.Element(Member.Skills.Element(I)(1))) & ": " & To_String(SkillLevel));
            CurrentLine := CurrentLine + 1;
        end loop;
        CurrentLine := CurrentLine + 1;
        case Member.Order is
            when Pilot =>
                OrderName := To_Unbounded_String("Piloting");
            when Engineer =>
                OrderName := To_Unbounded_String("Engineering");
            when Gunner =>
                OrderName := To_Unbounded_String("Gunner");
            when Rest =>
                OrderName := To_Unbounded_String("On break");
            when Repair =>
                OrderName := To_Unbounded_String("Repair ship");
            when Craft =>
                OrderName := To_Unbounded_String("Manufacturing");
            when Upgrading =>
                OrderName := To_Unbounded_String("Upgrading module");
            when Talk =>
                OrderName := To_Unbounded_String("Talking in bases");
            when Heal =>
                OrderName := To_Unbounded_String("Healing wounded");
            when Clean =>
                OrderName := To_Unbounded_String("Cleans ship");
        end case;
        Move_Cursor(Win => InfoWindow, Line => CurrentLine, Column => 0);
        Add(Win => InfoWindow, Str => "Order: " & To_String(OrderName));
        if Member.Tired < 100 and Member.Hunger < 100 and Member.Thirst < 100 then
            CurrentLine := CurrentLine + 2;
            Move_Cursor(Win => InfoWindow, Line => CurrentLine, Column => 0);
            Add(Win => InfoWindow, Str => "Press Enter to give orders to crew member");
            Change_Attributes(Win => InfoWindow, Line => CurrentLine, Column => 6, Count => 5, Color => 1);
        end if;
        Refresh;
        Refresh(InfoWindow);
        Delete(InfoWindow);
    end ShowMemberInfo;

    procedure ShowCrewInfo is
        Crew_Items: constant Item_Array_Access := new Item_Array(1..(PlayerShip.Crew.Last_Index + 1));
        MenuHeight : Line_Position;
        MenuLength : Column_Position;
    begin
        Move_Cursor(Line => 3, Column => 2);
        for I in PlayerShip.Crew.First_Index..PlayerShip.Crew.Last_Index loop
            Crew_Items.all(I) := New_Item(To_String(PlayerShip.Crew.Element(I).Name));
        end loop;
        Crew_Items.all(Crew_Items'Last) := Null_Item;
        CrewMenu := New_Menu(Crew_Items);
        Set_Format(CrewMenu, Lines - 10, 1);
        Set_Mark(CrewMenu, "");
        Scale(CrewMenu, MenuHeight, MenuLength);
        MenuWindow := Create(MenuHeight, MenuLength, 3, 2);
        Set_Window(CrewMenu, MenuWindow);
        Set_Sub_Window(CrewMenu, Derived_Window(MenuWindow, MenuHeight, MenuLength, 0, 0));
        Post(CrewMenu);
        if Crew_Items.all(MemberIndex) = Null_Item then
            MemberIndex := 1;
        end if;
        Set_Current(CrewMenu, Crew_Items.all(MemberIndex));
        ShowMemberInfo;
        Refresh(MenuWindow);
    end ShowCrewInfo;

    procedure ShowOrdersMenu is
        Orders_Items : Item_Array_Access;
        OrdersAmount : Positive := 1;
        MenuHeight : Line_Position;
        MenuLength : Column_Position;
        MenuIndex : Positive := 1;
        NeedRepairs, NeedHealer, HealOrder, NeedClean : Boolean := False;
    begin
        if PlayerShip.Crew.Element(MemberIndex).Tired = 100 or PlayerShip.Crew.Element(MemberIndex).Hunger = 100 or 
            PlayerShip.Crew.Element(MemberIndex).Thirst = 100 
        then
            Orders_Items := new Item_Array(1..3);  
            Orders_Items.all(1) := New_Item("Go on break", "0");
            MenuIndex := 2;
        else
            for I in PlayerShip.Crew.First_Index..PlayerShip.Crew.Last_Index loop
                if PlayerShip.Crew.Element(I).Health < 100 and I /= MemberIndex then
                    NeedHealer := True;
                    exit;
                end if;
            end loop;
            for I in PlayerShip.Modules.First_Index..PlayerShip.Modules.Last_Index loop
                if PlayerShip.Modules.Element(I).Durability > 0 then
                    case Modules_List.Element(PlayerShip.Modules.Element(I).ProtoIndex).MType is
                        when GUN =>
                            if PlayerShip.Modules.Element(I).Owner /= MemberIndex then
                                OrdersAmount := OrdersAmount + 1;
                            end if;
                        when ALCHEMY_LAB..GREENHOUSE =>
                            if PlayerShip.Modules.Element(I).Owner /= MemberIndex and PlayerShip.Modules.Element(I).Current_Value > 0 then
                                OrdersAmount := OrdersAmount + 1;
                            end if;
                        when MEDICAL_ROOM =>
                            if NeedHealer then
                                for J in PlayerShip.Cargo.First_Index..PlayerShip.Cargo.Last_Index loop
                                    if Items_List.Element(PlayerShip.Cargo.Element(J).ProtoIndex).IType = To_Unbounded_String("Medicines") 
                                        and PlayerShip.Crew.Element(MemberIndex).Order /= Heal 
                                        and PlayerShip.Crew.Element(MemberIndex).Health = 100
                                    then
                                        HealOrder := True;
                                        OrdersAmount := OrdersAmount + 1;
                                        exit;
                                    end if;
                                end loop;
                            end if;
                        when CABIN =>
                            if PlayerShip.Modules.Element(I).Current_Value < PlayerShip.Modules.Element(I).Max_Value and 
                                PlayerShip.Crew.Element(MemberIndex).Order /= Clean 
                            then
                                NeedClean := True;
                            end if;
                        when others =>
                            null;
                    end case;
                end if;
                if not NeedRepairs and PlayerShip.Modules.Element(I).Durability < PlayerShip.Modules.Element(I).MaxDurability then
                    for J in PlayerShip.Cargo.First_Index..PlayerShip.Cargo.Last_Index loop
                        if Items_List.Element(PlayerShip.Cargo.Element(J).ProtoIndex).IType = 
                            Modules_List.Element(PlayerShip.Modules.Element(I).ProtoIndex).RepairMaterial 
                        then
                            NeedRepairs := True;
                            exit;
                        end if;
                    end loop;
                end if;
            end loop;
            if NeedRepairs then
                OrdersAmount := OrdersAmount + 1;
            end if;
            if PlayerShip.Crew.Element(MemberIndex).Order /= Rest then
                OrdersAmount := OrdersAmount + 1;
            end if;
            if PlayerShip.UpgradeModule > 0 and PlayerShip.Crew.Element(MemberIndex).Order /= Upgrading then
                OrdersAmount := OrdersAmount + 1;
            end if;
            if PlayerShip.Speed = DOCKED and MemberIndex > 1 then
                OrdersAmount := OrdersAmount + 1;
            end if;
            if PlayerShip.Crew.Element(MemberIndex).Order /= Pilot then
                OrdersAmount := OrdersAmount + 1;
            end if;
            if PlayerShip.Crew.Element(MemberIndex).Order /= Engineer then
                OrdersAmount := OrdersAmount + 1;
            end if;
            if PlayerShip.Crew.Element(MemberIndex).Order /= Talk then
                OrdersAmount := OrdersAmount + 1;
            end if;
            if NeedClean then
                OrdersAmount := OrdersAmount + 1;
            end if;
            Orders_Items := new Item_Array(1..(OrdersAmount + 1));  
            if PlayerShip.Crew.Element(MemberIndex).Order /= Pilot then
                Orders_Items.all(MenuIndex) := New_Item("Piloting", "0");
                MenuIndex := MenuIndex + 1;
            end if;
            if PlayerShip.Crew.Element(MemberIndex).Order /= Engineer then
                Orders_Items.all(MenuIndex) := New_Item("Engineering", "0");
                MenuIndex := MenuIndex + 1;
            end if;
            for I in PlayerShip.Modules.First_Index..PlayerShip.Modules.Last_Index loop
                if PlayerShip.Modules.Element(I).Durability > 0 then
                    case Modules_List.Element(PlayerShip.Modules.Element(I).ProtoIndex).MType is
                        when GUN =>
                            if PlayerShip.Modules.Element(I).Owner /= MemberIndex then
                                Orders_Items.all(MenuIndex) := New_Item("Operate " & To_String(PlayerShip.Modules.Element(I).Name), 
                                Positive'Image(I));
                                MenuIndex := MenuIndex + 1;
                            end if;
                        when ALCHEMY_LAB..GREENHOUSE =>
                            if PlayerShip.Modules.Element(I).Owner /= MemberIndex and PlayerShip.Modules.Element(I).Current_Value > 0 then
                                Orders_Items.all(MenuIndex) := New_Item("Work in " & To_String(PlayerShip.Modules.Element(I).Name), 
                                Positive'Image(I));
                                MenuIndex := MenuIndex + 1;
                            end if;
                        when MEDICAL_ROOM =>
                            if HealOrder then
                                Orders_Items.all(MenuIndex) := New_Item("Heal wounded in " & To_String(PlayerShip.Modules.Element(I).Name), 
                                    Positive'Image(I));
                                MenuIndex := MenuIndex + 1;
                            end if;
                        when CABIN =>
                            if NeedClean and PlayerShip.Crew.Element(MemberIndex).Order /= Clean then
                                Orders_Items.all(MenuIndex) := New_Item("Clean ship", "0");
                                MenuIndex := MenuIndex + 1;
                                NeedClean := False;
                            end if;
                        when others =>
                            null;
                    end case;
                end if;
            end loop;
            if NeedRepairs then
                Orders_Items.all(MenuIndex) := New_Item("Repair ship", "0");
                MenuIndex := MenuIndex + 1;
            end if;
            if PlayerShip.UpgradeModule > 0 and PlayerShip.Crew.Element(MemberIndex).Order /= Upgrading then
                Orders_Items.all(MenuIndex) := New_Item("Upgrade module", "0");
                MenuIndex := MenuIndex + 1;
            end if;
            if PlayerShip.Crew.Element(MemberIndex).Order /= Talk then
                Orders_Items.all(MenuIndex) := New_Item("Talking in bases", "0");
                MenuIndex := MenuIndex + 1;
            end if;
            if PlayerShip.Crew.Element(MemberIndex).Order /= Rest then
                Orders_Items.all(MenuIndex) := New_Item("Go on break", "0");
                MenuIndex := MenuIndex + 1;
            end if;
            if PlayerShip.Speed = DOCKED and MemberIndex > 1 then
                Orders_Items.all(MenuIndex) := New_Item("Dismiss", "0");
                MenuIndex := MenuIndex + 1;
            end if;
        end if;
        Orders_Items.all(MenuIndex) := New_Item("Quit", "0");
        Orders_Items.all(Orders_Items'Last) := Null_Item;
        OrdersMenu := New_Menu(Orders_Items);
        Set_Mark(OrdersMenu, "");
        Set_Options(OrdersMenu, (Show_Descriptions => False, others => True));
        Scale(OrdersMenu, MenuHeight, MenuLength);
        MenuWindow2 := Create(MenuHeight + 2, MenuLength + 2, ((Lines / 3) - (MenuHeight / 2)), ((Columns / 2) - (MenuLength / 2)));
        Box(MenuWindow2);
        Set_Window(OrdersMenu, MenuWindow2);
        Set_Sub_Window(OrdersMenu, Derived_Window(MenuWindow2, MenuHeight, MenuLength, 1, 1));
        Post(OrdersMenu);
        Refresh;
        Refresh(MenuWindow2);
    end ShowOrdersMenu;

    procedure DismissMember is
        BaseIndex : constant Positive := SkyMap(PlayerShip.SkyX, PlayerShip.SkyY).BaseIndex;
    begin
        if PlayerShip.Speed /= DOCKED then
            ShowDialog("You can't dismiss crew members if you are not docked to base.");
            return;
        end if;
        if MemberIndex = 1 then
            ShowDialog("You can't dismiss self.");
            return;
        end if;
        for I in PlayerShip.Modules.First_Index..PlayerShip.Modules.Last_Index loop
            if PlayerShip.Modules.Element(I).Owner = MemberIndex then
                UpdateModule(PlayerShip, I, "Owner", "0");
            end if;
        end loop;
        AddMessage("You dismissed " & To_String(PlayerShip.Crew.Element(MemberIndex).Name) & ".", OrderMessage);
        PlayerShip.Crew.Delete(Index => MemberIndex, Count => 1);
        SkyBases(BaseIndex).Population := SkyBases(BaseIndex).Population + 1;
        MemberIndex := 1;
        DrawGame(Crew_Info);
    end DismissMember;

    function CrewInfoKeys(Key : Key_Code; OldState : GameStates) return GameStates is
        Result : Driver_Result;
    begin
        case Key is
            when Character'Pos('q') | Character'Pos('Q') => -- Back to sky map or combat screen
                MemberIndex := 1;
                DrawGame(OldState);
                return OldState;
            when 56 | KEY_UP => -- Select previous crew member
                Result := Driver(CrewMenu, M_Up_Item);
                if Result = Request_Denied then
                    Result := Driver(CrewMenu, M_Last_Item);
                end if;
                if Result = Menu_Ok then
                    MemberIndex := Get_Index(Current(CrewMenu));
                    ShowMemberInfo;
                    Refresh(MenuWindow);
                end if;
            when 50 | KEY_DOWN => -- Select next crew member
                Result := Driver(CrewMenu, M_Down_Item);
                if Result = Request_Denied then
                    Result := Driver(CrewMenu, M_First_Item);
                end if;
                if Result = Menu_Ok then
                    MemberIndex := Get_Index(Current(CrewMenu));
                    ShowMemberInfo;
                    Refresh(MenuWindow);
                end if;
            when 10 => -- Give orders to selected crew member
                ShowOrdersMenu;
                return Giving_Orders;
            when others =>
                Result := Driver(CrewMenu, Key);
                if Result = Menu_Ok then
                    MemberIndex := Get_Index(Current(CrewMenu));
                    ShowMemberInfo;
                    Refresh(MenuWindow);
                else
                    Result := Driver(CrewMenu, M_CLEAR_PATTERN);
                    Result := Driver(CrewMenu, Key);
                    if Result = Menu_Ok then
                        MemberIndex := Get_Index(Current(CrewMenu));
                        ShowMemberInfo;
                        Refresh(MenuWindow);
                    end if;
                end if;
        end case;
        return Crew_Info;
    end CrewInfoKeys;

    function CrewOrdersKeys(Key : Key_Code) return GameStates is
        Result : Driver_Result;
        ModuleIndex : constant Natural := Natural'Value(Description(Current(OrdersMenu)));
        OrderName : constant String := Name(Current(OrdersMenu));
    begin
        case Key is
            when 56 | KEY_UP => -- Select previous order
                Result := Driver(OrdersMenu, M_Up_Item);
                if Result = Request_Denied then
                    Result := Driver(OrdersMenu, M_Last_Item);
                end if;
                if Result = Menu_Ok then
                    Refresh(MenuWindow2);
                end if;
            when 50 | KEY_DOWN => -- Select next order
                Result := Driver(OrdersMenu, M_Down_Item);
                if Result = Request_Denied then
                    Result := Driver(OrdersMenu, M_First_Item);
                end if;
                if Result = Menu_Ok then
                    Refresh(MenuWindow2);
                end if;
            when 10 => -- Select order
                if OrderName = "Piloting" then
                    GiveOrders(MemberIndex, Pilot);
                elsif OrderName = "Engineering" then
                    GiveOrders(MemberIndex, Engineer);
                elsif OrderName = "Go on break" then
                    GiveOrders(MemberIndex, Rest);
                elsif OrderName = "Repair ship" then
                    GiveOrders(MemberIndex, Repair);
                elsif OrderName = "Upgrade module" then
                    GiveOrders(MemberIndex, Upgrading);
                elsif OrderName = "Talking in bases" then
                    GiveOrders(MemberIndex, Talk);
                elsif OrderName = "Heal wounded crew members" then
                    GiveOrders(MemberIndex, Heal, ModuleIndex);
                elsif OrderName = "Clean ship" then
                    GiveOrders(MemberIndex, Clean);
                elsif OrderName = "Dismiss" then
                    DrawGame(Dismiss_Confirm);
                    return Dismiss_Confirm;
                elsif OrderName /= "Quit" then
                    if Modules_List.Element(PlayerShip.Modules.Element(ModuleIndex).ProtoIndex).MType = GUN then
                        GiveOrders(MemberIndex, Gunner, ModuleIndex);
                    else
                        GiveOrders(MemberIndex, Craft, ModuleIndex);
                    end if;
                end if;
                DrawGame(Crew_Info);
                return Crew_Info;
            when others =>
                Result := Driver(OrdersMenu, Key);
                if Result = Menu_Ok then
                    Refresh(MenuWindow2);
                else
                    Result := Driver(OrdersMenu, M_CLEAR_PATTERN);
                    Result := Driver(OrdersMenu, Key);
                    if Result = Menu_Ok then
                        Refresh(MenuWindow2);
                    end if;
                end if;
        end case;
        return Giving_Orders;
    end CrewOrdersKeys;

end Crew.UI;
