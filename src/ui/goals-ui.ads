--    Copyright 2018-2019 Bartek thindil Jasicki
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

-- ****h* Steamsky/Goals.UI
-- FUNCTION
-- Provides code for selecting goals UI
-- SOURCE
package Goals.UI is
-- ****

   -- ****f* Goals.UI/CreateGoalsMenu
   -- FUNCTION
   -- Create goals menu
   -- SOURCE
   procedure CreateGoalsMenu;
   -- ****

   -- ****f* Goals.UI/ShowGoalsMenu
   -- FUNCTION
   -- Show goals selection menu to player
   -- PARAMETERS
   -- InMainMenu - If true, show UI in main menu game state. Default is true
   -- SOURCE
   procedure ShowGoalsMenu(InMainMenu: Boolean := True);
   -- ****

end Goals.UI;
