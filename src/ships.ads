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

with Terminal_Interface.Curses; use Terminal_Interface.Curses;
with Ada.Containers.Vectors; use Ada.Containers;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Crew; use Crew;
with Game; use Game;

package Ships is
    type ShipSpeed is (DOCKED, FULL_STOP, QUARTER_SPEED, HALF_SPEED,
        FULL_SPEED);
    type ModuleData is -- Data structure for ship modules
        record
            Name : Unbounded_String; -- Name of module
            ProtoIndex : Positive; -- Index of module prototype
            Weight : Natural; -- Weight of module
            Current_Value : Integer; -- For engine, current power, depends on module
            Max_Value : Integer; -- For engine, max power, depends on module
            Durability : Integer; -- 0 = destroyed
            MaxDurability : Integer; -- Base durability
        end record;
    package Modules_Container is new Vectors(Positive, ModuleData); 
    type CargoData is -- Data structure for ship cargo
        record
            ProtoIndex : Positive; -- Index of prototype
            Amount : Positive; -- Amount of cargo
        end record;
    package Cargo_Container is new Vectors(Positive, CargoData);
    package Crew_Container is new Vectors(Positive, Member_Data);
    type ShipRecord is -- Data structure for ships
        record
            Name : Unbounded_String; -- Ship name
            SkyX : Integer; -- X coordinate on sky map
            SkyY : Integer; -- Y coordinate on sky map
            Speed : ShipSpeed; -- Speed of ship
            Craft : Natural; -- Recipe number to craft on ship
            Modules : Modules_Container.Vector; -- List of ship modules
            Cargo : Cargo_Container.Vector; -- List of ship cargo
            Crew : Crew_Container.Vector; -- List of ship crew
        end record;
    package ProtoModules_Container is new Vectors(Positive, Positive);
    type ProtoShipData is -- Data structure for ship prototypes
        record
            Name : Unbounded_String; -- Prototype name
            Modules : ProtoModules_Container.Vector; -- List of ship modules
            Damage : Positive; -- Damage done by ship
            DamageRange : Positive; -- Maximum range from which ship attack
            Accuracy : Positive; -- Bonus to hit for ship
        end record;
    package ProtoShips_Container is new Vectors(Positive, ProtoShipData);
    ProtoShips_List : ProtoShips_Container.Vector;
    PlayerShip : ShipRecord;
    
    procedure MoveShip(ShipIndex, X, Y : Integer); -- Move selected ship
    procedure DockShip(Docking : Boolean); -- Dock/Undock ship at base
    procedure ChangeShipSpeed(SpeedValue : ShipSpeed); -- Change speed of ship
    procedure UpdateCargo(ProtoIndex : Positive; Amount : Integer); -- Update selected item in ship cargo
    procedure UpdateModule(Ship : in out ShipRecord; ModuleIndex : Positive; Field : String; Value : String); -- Update selected module
    function FreeCargo(Amount : Integer) return Integer; -- Return available space in cargo after adding/extracting Amount
    function CreateShip(ProtoIndex : Positive; Name : Unbounded_String; X, Y:
        Integer; Speed : ShipSpeed ) return ShipRecord; -- Create new ship
    procedure LoadShips; -- Load ships from file
    procedure ShowShipInfo; -- Show informations about ship status
    procedure ShowCargoInfo; -- Show informations about ship cargo
    function ShipInfoKeys(Key : Key_Code) return GameStates; -- Handle keys in ship info menu

end Ships;
