create database las_delicias_de_mary
use las_delicias_de_mary;
-
--- Tabla roles (RF-09, RF-11)
CREATE TABLE roles (
    id_rol INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(30) NOT NULL UNIQUE
);
 
-- Tabla usuarios (RF-01, RF-11)
-- La contraseña se guarda como hash bcrypt. Las cuentas no se borran, se desactivan.
CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    id_rol INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    bloqueado BOOLEAN NOT NULL DEFAULT FALSE,
    intentos_fallidos INT NOT NULL DEFAULT 0,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
);
 
-- Tabla mesas (RF-02)
CREATE TABLE mesas (
    id_mesa INT PRIMARY KEY AUTO_INCREMENT,
    numero INT NOT NULL UNIQUE,
    capacidad INT NOT NULL,
    estado ENUM('DISPONIBLE', 'OCUPADA', 'RESERVADA') NOT NULL DEFAULT 'DISPONIBLE',
    activa BOOLEAN NOT NULL DEFAULT TRUE
);
 
-- Tabla insumos - ingredientes con los que el mesero ARMA los platos (RF-05, RF-06)
--   BASE = arroz | PRINCIPIO = frijoles, lentejas, pastas
--   PROTEINA = cerdo asado, pollo a la plancha | ACOMPANAMIENTO = maduro, ensalada
CREATE TABLE insumos (
    id_insumo INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    tipo ENUM('BASE', 'PRINCIPIO', 'PROTEINA', 'ACOMPANAMIENTO') NOT NULL,
    disponible BOOLEAN NOT NULL DEFAULT TRUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);
 
-- Tabla categorias del menu fijo (especiales del dia, jugos, gaseosas, adicionales)
CREATE TABLE categorias (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL UNIQUE
);
 
-- Tabla platos - menu FIJO que el mesero ofrece (RF-05, RF-06)
-- El precio es informativo (no hay facturacion).
CREATE TABLE platos (
    id_plato INT PRIMARY KEY AUTO_INCREMENT,
    id_categoria INT NOT NULL,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    precio DECIMAL(10,2) NOT NULL,
    disponible BOOLEAN NOT NULL DEFAULT TRUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);
 
-- Tabla pedidos / comandas (RF-03, RF-04, RF-07, RF-08, RF-10, RF-12)
-- Una mesa puede tener varios pedidos vigentes (regla R3).
CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    numero INT NOT NULL UNIQUE,
    id_mesa INT NOT NULL,
    id_usuario INT NOT NULL,
    estado ENUM('PENDIENTE', 'EN_PREPARACION', 'LISTO', 'ENTREGADO', 'CANCELADO') NOT NULL DEFAULT 'PENDIENTE',
    fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_mesa) REFERENCES mesas(id_mesa),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);
 
-- Tabla detalle_pedido - cada linea de la comanda (RF-03, RF-12)
--   tipo ARMADO -> id_plato queda NULL y sus insumos van en detalle_pedido_insumo
--   tipo MENU   -> id_plato apunta al producto del menu fijo
-- ON DELETE CASCADE - si se borra un pedido, se borran sus lineas.
CREATE TABLE detalle_pedido (
    id_detalle_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    tipo ENUM('ARMADO', 'MENU') NOT NULL,
    id_plato INT,
    cantidad INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(10,2),
    observaciones VARCHAR(255),
    cancelado BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_plato) REFERENCES platos(id_plato)
);
 
-- Tabla detalle_pedido_insumo - insumos elegidos para cada plato ARMADO
-- La clave primaria es la pareja (linea, insumo) para no repetir un insumo en el mismo plato.
CREATE TABLE detalle_pedido_insumo (
    id_detalle_pedido INT NOT NULL,
    id_insumo INT NOT NULL,
    PRIMARY KEY (id_detalle_pedido, id_insumo),
    FOREIGN KEY (id_detalle_pedido) REFERENCES detalle_pedido(id_detalle_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_insumo) REFERENCES insumos(id_insumo)
);
