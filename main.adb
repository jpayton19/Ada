--Program Name: Lab3
--Student Names: Duncan Scott Martinson & John Payton
--Semester: Spring 2017
--Class: COSC 30403
--Instructor: Dr. James Comer
--Due Date: 3/7/2017

--Program Overview:
   --This Ada program uses a text file to input data into a linked list of
   --Employees and execute commands in order to manipulate the list. After every
   --command, the program writes information about the execution to a separate text file.
   --After all the data from the file has been read, the program terminates.

--Input:
   --The program requires formatted data in a text file entitled "Lab3Data.txt"

--Output:
   --The program outputs a data file entitled "Lab3Ans.txt" containing information
   --about the program's execution.

--Program Limitations:
   --1) The program does not allow for real time user interaction, and the output file
   --is overwritten after every execution.
   --2) No leading zeros.


--Significant Program Variables:
   --input - the identifier for the input file
   --output - the identifier for the output file
   --cmd - a string that stores the first three characters read from a line of input. This is used to
       --determine the appropriate subroutine to execute.
   --head - a Pointer to an Employee node that serves as the list head. Used to reference the linked list.
   --current- an Employee Node pointer used in almost every procedure. Is used to traverse the list and
           --analyze data, manipulating it if need be.


--Packages
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Strings.Bounded; use Ada.Strings.Bounded;
with Interfaces.C_Streams; use Interfaces.C_Streams;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Strings; use Ada.Strings;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
--Main Procedure
procedure Main is
   --Type Definitions for the Data Structure
   type Node;
   type Pointer is access all Node;
   type Employee is record
      id : Integer;
      name : String(1..12);
      dept : String(1..16);
      title : String(1..16);
      pay : Float;
   end record;
   type Node is record
      data : Employee;
      next : Pointer := null;
   end record;
--Global Variables
   head : Pointer;
   input, output : File_Type;
   cmd : String(1..3);
   temp : Employee;
   targetID : Integer;
   tempName : String(1..12);
   tempDT : String(1..16);
   tempPay : Float;
   leadingZeros : String(1..8);
--This Procedure Initializes the linked list.
   procedure initList is
   begin
      head := new Node;
      head.data.id := 0;
      head.data.pay:=0.0;
   end;
   --This procedure inserts a new employee into the data structure. By looking one
   --down the list, it avoids wasting memory on using a doubly-linked list.
   procedure insert(newEmp : in Employee) is
      current : Pointer;
      newNode : Pointer;
      --tempTarget : aliased Node;
   begin
      --tempTarget.data := newEmp;
      newNode := new Node;
      newNode.data := newEmp;
      current := head;
      while(true) loop
         if(current.next = null) then
            current.next := newNode;
            Put(output, "Employee #");
            Put(output, newNode.data.id, 8);
            Put_Line(output, " inserted.");
            exit;
         elsif(newNode.data.id<current.next.data.id) then
            newNode.next:=current.next;
            current.next := newNode;
            Put(output, "Employee #");
            Put(output, newNode.data.id, 8);
            Put_Line(output, " inserted.");
            exit;
         else
            current:= current.next;
         end if;

      end loop;
   end insert;
   --This procedure prints out all of the information of an employee. A helper
   --procedure to every print procedure
   procedure printEmployee(target : in Employee) is
   begin
      Put(output, target.id, 8);
      Put(output, " " & target.name & " " & target.dept & " " & target.title & " ");
      Put(output, target.pay, 3,2,0);
      Put_Line(output, "");
      Put(target.id, 8);
      Put(" " & target.name & " " & target.dept & " " & target.title & " ");
      Put(target.pay, 3,2,0);
      Put_Line("");
   end printEmployee;

   --This procedure prints out all the information in every node in the list.
   procedure printAll is
      current: Pointer := head;
   begin
      current := current.next;
      Put_Line(output, "BEGIN PRINT ALL:");
      Put_Line("BEGIN PRINT ALL:");
      while true loop
         if(current = null) then
            exit;
         end if;
         printEmployee(current.data);
         current:=current.next;
      end loop;
      Put_Line(output, "END PRINT ALL.");
      Put_Line("END PRINT ALL.");

   end printAll;

   --This procedure prints out all the information of an employee with the
   --given id number.
   procedure printID(num : in Integer) is
      found : Boolean := False;
      current : Pointer := head;
   begin
      current := current.next;
      while true loop
         if(current = null) then
            exit;
         elsif (current.data.id = num) then
            Put(output, "Print Employee: ");
            printEmployee(current.data);
            found := True;
            exit;
         else
            current := current.next;
         end if;
      end loop;
      if not found then
         Put(output, "PI ERROR: Employee #");
         Put(output, num, 8);
         Put_Line(output, " not found.");
      end if;

   end printID;

   --This procedure prints out all the information for every employee in the
   --given department.
   procedure printDept(department : in String) is
      found : Boolean := False;
      current : Pointer := head;
   begin
      Put_Line(output, "BEGIN PRINT DEPARTMENT: " & department);
      while true loop
         if(current = null) then
            exit;
         elsif(Trim(current.data.dept, Both) = Trim(department, Both)) then
            printEmployee(current.data);
            found := true;
            current := current.next;
         else
            current := current.next;
         end if;
      end loop;
      if (not found) then
         Put_Line(output, "ERROR: Department not found: " & department);
      end if;
      Put_Line(output, "END PRINT DEPARTMENT.");
   end printDept;

   --This procedure updates the name of an employee with the given
   --id number.
   procedure updateName(num : in Integer; newName : in String) is
      current : Pointer := head;
      found: Boolean := false;
   begin
      while true loop
         if(current.next.data.id = num) then
            current.next.data.name:= newName;
            Put(output, "Employee #");
            Move(num'Img, leadingZeros, Right, Right, '0');
            Put(output, leadingZeros);
            Put_Line(output, " name updated to " & newName);
            found := true;
            exit;
         elsif (current.next = null) then
            exit;
         else
            current := current.next;
         end if;
      end loop;
      if (not found) then
         Put(output, "UN ERROR: Employee #");
         Put(output, num, 8);
         Put_Line(output, " not found.");
      end if;
   end updateName;

   procedure updateDept(num : in Integer; newData : in String) is
      current : Pointer := head;
      found: Boolean := false;
   begin
      while true loop
         if(current.next.data.id = num) then
            current.next.data.dept:= newData;
            Put(output, "Employee #");
            Put(output, num, 8, 10);
            Put_Line(output, " department updated to " & newData);
            found := true;
            exit;
         elsif (current.next = null) then
            exit;
         else
            current := current.next;
         end if;
      end loop;
      if (not found) then
         Put(output, "UD ERROR: Employee #");
         Put(output, num, 8);
         Put_Line(output, " not found.");
      end if;
   end updateDept;

   --This procedure updates the title of an employee with the given id number.
   procedure updateTitle(num : in Integer; newData : in String) is
      current : Pointer := head;
      found: Boolean := false;
   begin
      while true loop
         if(current.next.data.id = num) then
            current.next.data.dept:= newData;
            Put(output, "Employee #");
            Put(output, num, 8);
            Put_Line(output, " title updated to " & newData);
            found := true;
            exit;
         elsif (current.next = null) then
            exit;
         else
            current := current.next;
         end if;
      end loop;
      if (not found) then
         Put(output, "UT ERROR: Employee #");
         Put(output, num, 8);
         Put_Line(output, " not found.");
      end if;
   end updateTitle;

   --This procedure updates the pay of an employee with the given id number.
   procedure updatePay(num : in Integer; newData : in Float) is
      current : Pointer := head;
      found: Boolean := false;
      oldData: Float;
   begin
      while true loop
         if(current.next.data.id = num) then
            oldData:= current.next.data.pay;
            current.next.data.pay := newData;
            Put(output, "Employee #");
            Put(output, num, 8);
            Put(output, " pay updated from ");
            Put(output, oldData, 3, 2, 0);
            Put(output, " to ");
            Put(output, newData, 3, 2, 0);
            Put_Line(output, ".");
            found := true;
            exit;
         elsif (current.next = null) then
            exit;
         else
            current := current.next;
         end if;
      end loop;
      if (not found) then
         Put(output, "UR ERROR: Employee #");
         Put(output, num, 8);
         Put_Line(output, " not found.");
      end if;
   end updatePay;

   --This procedure deletes an employee with the given id number from the list.
   procedure delete(num : in Integer) is
      current : Pointer := head;
      found : Boolean := False;
   begin
      while true loop
         if(current.next = null) then
            exit;
         elsif(current.next.data.id = num) then
            found := True;
            current.next := current.next.next;
            Put(output, "Employee #");
            Put(output, num, 8);
            Put_Line(output, " deleted.");
            exit;
         else
            current := current.next;
         end if;
      end loop;
      if(not found) then
         Put(output, "DE ERROR: Employee #");
         Put(output, num, 8);
         Put_Line(output, " not found.");
      end if;
   end delete;




--The body of the main procedure
begin
   --Initialize the list
   initList;
   --Prepare the I/O
   open(File => input, Name => "Lab3Data.txt", Mode => In_File);
   create(File => output, Name=> "Lab3Ans.txt", Mode => Out_File);
   Reset(File => input, Mode => In_File);
   Reset(File => output, Mode => Out_File);
   Put_Line(output, "BEGIN PROGRAM:");

   --Loop until the end of the file
   loop
      exit when End_Of_File(input);
      --Get the command
      Get(input, cmd);
      --Execute the appropriate procedure
      if(cmd = "IN ") then
         get(input, temp.id);
         get(input, temp.name);
         get(input, temp.dept);
         get(input, temp.title);
         get(input, temp.pay);
         insert(temp);
      elsif  (cmd = "PA ") then
         printAll;
         Skip_Line(input);
      elsif(cmd = "PI ") then
         get(input, targetID);
         printID(targetID);
         Skip_Line(input);
      elsif(cmd = "PD ") then
         get(input, tempDT);
         printDept(tempDT);
         Skip_Line(input);
      elsif(cmd = "UN ") then
         get(input, targetID);
         get(input, tempName);
         get(input, tempDT);
         get(input, tempName);
         updateName(targetID, tempName);
         Skip_Line(input);
      elsif(cmd = "UD ") then
         get(input, targetID);
         get(input, tempName);
         get(input, tempDT);
         get(input, tempDT);
         updateDept(targetID, tempDT);
         Skip_Line(input);
      elsif(cmd = "UT ") then
         get(input, targetID);
         get(input, tempName);
         get(input, tempDT);
         get(input, tempDT);
         updateTitle(targetID, tempDT);
         Skip_Line(input);
      elsif(cmd = "UR ") then
         get(input, targetID);
         get(input, tempName);
         get(input, tempDT);
         get(input, tempPay);
         updatePay(targetID, tempPay);
         Skip_Line(input);
      elsif(cmd = "DE ") then
         get(input, targetID);
         delete(targetID);
         Skip_Line(input);
      end if;

   end loop;
   Put_Line(output, "END PROGRAM.");
   --Cleanup
   Close(input);
   Close(output);
end Main;
