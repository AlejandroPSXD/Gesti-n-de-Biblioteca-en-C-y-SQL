-- Query Creación de base de datos de Residencia Progra IV

--Creación de la base de datos
Create database db_ResidenciaDAAI

Use db_ResidenciaDAAI

--////////////////////////////////////////
--Tablas
begin

Create table tbl_Usuarios(
	idUsuario int identity primary key,
	nombre varchar(30) not null,
	apellidop varchar(30) not null,
	apellidom varchar(30) not null,
	passw varchar(30) null,
	estado varchar(30) not null, --/Habilitado, inhabilitado o eliminado
	puesto varchar(30) not null,
);

Create table tbl_Productos(
	idProducto Int Primary Key Identity(1,1),
	NombreP Varchar (30) not null,
	MarcaP Varchar (30) not null,
	CantidadP Int not null,
);
end
--////////////////////////////////////////



--////////////////////////////////////////
--SPR Productos
begin

--SPR para Insertar productos
Create Procedure SPR_InsertarProductos
@nombre varchar(30),
@marca varchar(30),
@cantidad int

As
	Begin
		Insert into tbl_Productos values (@nombre, @marca, @cantidad)
	End

exec SPR_InsertarProductos 'Arte de Guerra', 'Predo Pedrito', 18
exec SPR_InsertarProductos 'A vivir', 'Fernando Ojeda', 15
exec SPR_InsertarProductos 'Prueba', 'Eugenop', 14
exec SPR_InsertarProductos 'Buscando la orilla', 'Juana Veloz', 10
select * from tbl_Productos

--SPR para mostrar productos
Create Procedure SPR_MostrarProductos
As
	Begin
		select * from tbl_Productos
	End


--SPR para actualizar productos
Create Procedure SPR_ActualizarProducto
@id int,
@nombre varchar(30),
@marca varchar(30),
@cantidad int
As
begin
	Update tbl_Productos set NombreP = @nombre, marcaP = @marca, cantidadP = @cantidad Where idProducto = @id
End
exec SPR_ActualizarProducto 1, 'Arte de Guerra', 'Predo Pedrito', 15
select * from tbl_Productos

--SPR para Eliminar productos
Create Procedure SPR_EliminarProducto
@idProducto int
as 
begin
		delete from tbl_Productos where idProducto=@idProducto
end
end
--////////////////////////////////////////



--////////////////////////////////////////
--SPR para Insertar Usuarios
begin
Alter Procedure SPR_InsertarUsuarios
@nombre varchar(30),
@apellidop varchar(30),
@apellidom varchar(30),
@pass varchar(30),
@estado varchar(30),
@puesto varchar(30)
As
	Begin
		Insert into tbl_Usuarios values (@nombre, @apellidop, @apellidom, @pass, @estado, @puesto )
	End
End
exec spr_insertarUsuarios 'Alejandro', 'Porras', 'Soto', '1234', 'Habilitado', 'Administrador'
exec spr_insertarUsuarios 'Robert', 'Kawasaki', 'Mirazama', '1234', 'Habilitado', 'Administrador'
exec spr_insertarUsuarios 'Jeff', 'Thompson', 'Just', '1234', 'Habilitado', 'Bibliotecario'
exec spr_insertarUsuarios 'Eugenio', 'Barras', 'Delado', '', 'Habilitado', 'Docente'
exec spr_insertarUsuarios 'Belisa', 'Soto', 'Alfaro', '', 'Habilitado', 'Estudiante'
select * from tbl_Usuarios

--SPR para mostrar usuarios
Create Procedure SPR_MostrarUsuarios
As
	Begin
		select * from tbl_Usuarios
	End


--SPR para actualizar Usuarios
Alter Procedure SPR_ActualizarUsuarios
@id int,
@nombre varchar(30),
@apellidop varchar(30),
@apellidom varchar(30),
@pass varchar(30),
@estado varchar(30),
@puesto varchar(30)

As
begin
	Update tbl_Usuarios set nombre = @nombre, apellidop = @apellidop, apellidom = @apellidom, passw = @pass, estado = @estado, puesto = @puesto  Where idUsuario = @id
End
Exec SPR_ActualizarUsuarios 5,'Belisa','Soto', 'Soto', '', 'Habilitado', 'Estudiante'
select *from tbl_Usuarios

--SPR para Eliminar Usuarios
Create Procedure SPR_EliminarUsuarios
@idUs int
as
	begin
		delete from tbl_Usuarios where idUsuario=@idUs
end
exec SPR_EliminarUsuarios 3

--SPR Login
Begin
Alter Procedure SPR_Login
@nombre varchar(30),
@contraseña varchar (30)
As
	Begin
		select nombre, passw, puesto, estado from tbl_Usuarios where nombre = @nombre and passw = @contraseña
	End
End
--////////////////////////////////////////

select * from tbl_Usuarios

--////////////////////////////////////////
--Triggers Usuarios
begin

--Trigger Delete de Usuarios       
Create table tbl_ControlDeleteUsuarios( 
	id int Primary Key,
	nombreUs varchar(30) not null,
	nombreUBD varchar(30) not null,
	fecha datetime not null,
	operacion varchar(20) not null
);
Create trigger BajaUsuarioControl on tbl_Usuarios
for delete 
as
begin
	insert into tbl_ControlDeleteUsuarios(id,nombreUs,nombreUBD,fecha,operacion) select deleted.idUsuario ,deleted.nombre, user_name(),GETDATE(), 'Baja'
	from deleted
end


--Trigger Insert de Usuarios
Create table tbl_ControlInsertUsuarios( 
	id int Primary Key,
	nombreUs varchar(30) not null,
	nombreUBD varchar(30) not null,
	fecha datetime not null,
	operacion varchar(20) not null
);

Create trigger InsertUsuarioControl on tbl_Usuarios
for insert 
as
begin
	insert into tbl_ControlInsertUsuarios(id,nombreUs,nombreUBD,fecha,operacion) select inserted.idUsuario, inserted.nombre, user_name(),GETDATE(), 'Inserción'
	from inserted
end
end

--////////////////////////////////////////

--////////////////////////////////////////
--Trigger Operaciones Realizadas
Create table tbl_ControlOperacionesRealizadas(
	id int,
	nombreP varchar(30) not null,
	nombreUBD varchar(30) not null,
	fecha datetime not null,
	operacion varchar(20) not null
)
Alter trigger OPeracionesRealizadasControl
on tbl_Productos
for update 
as
Begin
	if update (CantidadP)
		begin
			Update tbl_Productos set CantidadP = inserted.CantidadP from tbl_Productos, inserted, deleted
			where tbl_Productos.idProducto = deleted.idProducto;
			insert into tbl_ControlOperacionesRealizadas(id, nombreP,nombreUBD,fecha,operacion) select inserted.idProducto, inserted.NombreP, user_name(),GETDATE(), 'Operación Realizada'
			from inserted
		end
	Else
		begin
			Raiserror ('No fue posible ejecutar el trigger', 10,1)
			rollback
	end
end

--Ejecutar y Probar el Trigger
Update tbl_Productos set CantidadP = 10 where idProducto = 1
select * from tbl_Productos
select * from tbl_ControlOperacionesRealizadas
