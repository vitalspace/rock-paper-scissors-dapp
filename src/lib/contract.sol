// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

contract PiedraPapelTijera {
    enum Opcion {Ninguna, Piedra, Papel, Tijera}
    
    mapping (uint => mapping(uint => int)) private resultados;
    
    event Juego(address jugador, Opcion opcionJugador, Opcion opcionContrato, int8 resultado);
    
    constructor() {
        resultados[uint(Opcion.Piedra)][uint(Opcion.Piedra)] = 0;
        resultados[uint(Opcion.Piedra)][uint(Opcion.Papel)] = -1;
        resultados[uint(Opcion.Piedra)][uint(Opcion.Tijera)] = 1;
        resultados[uint(Opcion.Papel)][uint(Opcion.Piedra)] = 1;
        resultados[uint(Opcion.Papel)][uint(Opcion.Papel)] = 0;
        resultados[uint(Opcion.Papel)][uint(Opcion.Tijera)] = -1;
        resultados[uint(Opcion.Tijera)][uint(Opcion.Piedra)] = -1;
        resultados[uint(Opcion.Tijera)][uint(Opcion.Papel)] = 1;
        resultados[uint(Opcion.Tijera)][uint(Opcion.Tijera)] = 0;
    }
    
    function jugar(uint opcion) public returns (int8) {
        require(opcion >= 1 && opcion <= 3, "Opcion invalida. Debe ser 1 (piedra), 2 (papel) o 3 (tijera).");
        
        Opcion opcionJugador = Opcion(opcion);
        Opcion opcionContrato = Opcion(uint(blockhash(block.number - 1)) % 3 + 1);
        
        int8 resultado = int8(resultados[uint(opcionJugador)][uint(opcionContrato)]);
        
        emit Juego(msg.sender, opcionJugador, opcionContrato, resultado);
        return resultado;
    }
}
