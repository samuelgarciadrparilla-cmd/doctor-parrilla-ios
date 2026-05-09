# Claude Code Skill — Production Grade

## CONTEXT

Proyecto profesional. Código que va a producción.
NO scripts experimentales. Quality first.

## CORE PRINCIPLES

### 1. CALIDAD SOBRE VELOCIDAD

- Pensá antes de escribir
- Mejor 10 líneas perfectas que 100 con bugs
- Si dudás → preguntá, no asumas

### 2. CÓDIGO LIMPIO (Robert Martin)

- Funciones < 20 líneas
- Una responsabilidad por función
- Nombres descriptivos en inglés
- Sin comentarios obvios
- Comentarios solo para "por qué", no "qué"

### 3. SOLID PRINCIPLES

- Single Responsibility
- Open/Closed
- Liskov Substitution
- Interface Segregation
- Dependency Inversion

### 4. ZERO DEUDA TÉCNICA

- Nada de "TODO" sin issue
- Nada de "FIXME" en main
- Nada de console.log olvidados
- Nada de código comentado

## CODE STANDARDS

### Naming

```
✅ getUserActiveOrders()
❌ getData()
❌ doStuff()
❌ handleIt()

✅ const MAX_RETRY_ATTEMPTS = 3
❌ const x = 3
❌ const num = 3
```

### Functions

```python
# ✅ BIEN
def calculate_order_total(
    items: list[OrderItem],
    discount: Decimal = Decimal("0")
) -> Decimal:
    """Calcula total con descuento aplicado."""
    subtotal = sum(item.price * item.qty for item in items)
    return subtotal * (1 - discount)

# ❌ MAL  
def calc(i, d=0):
    t = 0
    for x in i:
        t = t + x.p * x.q
    return t * (1 - d)
```

### Error Handling

```python
# ✅ SIEMPRE específico
try:
    response = api.fetch_data()
except APITimeoutError as e:
    logger.warning(f"Timeout: {e}")
    return cached_fallback()
except APIRateLimitError as e:
    logger.error(f"Rate limit: {e}")
    raise
except APIError as e:
    logger.error(f"API failed: {e}", exc_info=True)
    raise ServiceUnavailableError() from e

# ❌ NUNCA genérico
try:
    response = api.fetch_data()
except:
    pass  # Esto es delito
```

### Type Safety

- Type hints OBLIGATORIOS en Python
- TypeScript estricto (no `any`)
- Dart: usar tipos explícitos
- Validar tipos en runtime cuando
  vienen de afuera (API, user input)

## ARCHITECTURE RULES

### Separation of Concerns

```
src/
├── domain/        # Lógica de negocio pura
├── application/   # Use cases / orquestación
├── infrastructure/ # APIs, DB, externos
└── presentation/  # UI, controllers
```

### Dependency Injection

- No hardcodear dependencias
- Inyectar via constructor
- Testeable por diseño

### No God Objects

- Si una clase tiene >300 líneas → dividir
- Si un archivo tiene >500 líneas → dividir
- Si una función tiene >5 parámetros → refactor

## TESTING

### Coverage Mínimo

- Domain layer: 95%+
- Application layer: 85%+
- Infrastructure: 70%+
- Tests obligatorios para:
  - Cálculos financieros
  - Lógica de negocio crítica
  - Manejo de errores

### Test Quality

```python
# ✅ BIEN - explícito y claro
def test_calculate_total_with_20_percent_discount():
    items = [OrderItem(price=100, qty=2)]
    result = calculate_order_total(items, Decimal("0.2"))
    assert result == Decimal("160.00")

# ❌ MAL - confuso
def test_1():
    assert calc([{"p":100,"q":2}], 0.2) == 160
```

## SECURITY

### NUNCA EN EL CÓDIGO

- API keys
- Passwords
- Private keys
- Database URLs con credentials
- Tokens

### SIEMPRE

- Variables de entorno
- .env en .gitignore
- Validación de inputs
- Sanitización de outputs
- Rate limiting en APIs públicas
- HTTPS obligatorio
- SQL injection prevention
- XSS prevention

## PERFORMANCE

### REGLAS

- N+1 queries → ABSOLUTAMENTE NO
- Loops anidados → revisar siempre
- Memoria: limpiar listeners
- Bundle size: tree shaking
- Lazy loading donde aplique
- Cache estratégico

### PROFILING

- Medí antes de optimizar
- "Premature optimization is the
  root of all evil" — Donald Knuth
- Pero NO escribas ineficiente
  a propósito

## DOCUMENTATION

### Code Documentation

```python
def transfer_funds(
    from_account: str,
    to_account: str,
    amount: Decimal
) -> TransferResult:
    """
    Transfiere fondos entre cuentas.
    
    Args:
        from_account: ID cuenta origen
        to_account: ID cuenta destino
        amount: Monto a transferir
    
    Returns:
        TransferResult con tx_id y status
    
    Raises:
        InsufficientFundsError: Si saldo < amount
        AccountNotFoundError: Si cuenta no existe
        InvalidAmountError: Si amount <= 0
    
    Example:
        >>> result = transfer_funds("acc1", "acc2", Decimal("100"))
        >>> result.status
        'completed'
    """
```

### README

Cada proyecto debe tener:

- Descripción clara
- Setup paso a paso
- Variables de entorno
- Cómo correr tests
- Cómo deployar
- Troubleshooting común

## GIT WORKFLOW

### Commits

```
✅ feat: add user authentication via SMS
✅ fix: resolve memory leak in WebSocket
✅ refactor: extract payment validation
✅ test: add coverage for order calculator

❌ updates
❌ fix bug
❌ wip
❌ asdf
```

### Conventional Commits

- feat: nueva funcionalidad
- fix: corrección de bug
- refactor: refactorización
- test: tests
- docs: documentación
- chore: tareas mantenimiento
- perf: mejora performance
- style: formato (no afecta lógica)

## REVIEW CHECKLIST

Antes de declarar "terminado":

- [ ] Compila sin warnings
- [ ] Tests pasan al 100%
- [ ] Coverage cumple mínimo
- [ ] Linter sin errores
- [ ] Type checker sin errores
- [ ] Sin código muerto
- [ ] Sin TODOs nuevos
- [ ] Sin console.log/print debug
- [ ] README actualizado
- [ ] CHANGELOG actualizado
- [ ] Variables sensibles en .env
- [ ] .gitignore completo

## MODEL USAGE

### opusplan obligatorio

- Opus: planificación, arquitectura,
  decisiones de diseño, debugging complejo
- Sonnet: implementación, refactor,
  tests, documentación

### Cuando usar Opus explícito

- Decisiones de arquitectura
- Debugging difícil
- Algoritmos complejos
- Análisis de seguridad

## COMMUNICATION RULES

### Cuando reportes:

- Sé específico (no "funciona")
- Mostrá métricas concretas
- Antes/después si aplica
- Honesto sobre lo que NO funciona
- Sin exageraciones

### Cuando preguntes:

- Una pregunta a la vez
- Con contexto necesario
- Con tu hipótesis
- Esperá respuesta antes de avanzar

## WHAT NEVER TO DO

❌ Usar `any` en TypeScript
❌ Usar `dynamic` en Dart sin razón
❌ Try/except sin tipo específico
❌ Variables mágicas (números sin nombre)
❌ Funciones >50 líneas
❌ Clases >300 líneas
❌ Files >500 líneas
❌ Hardcodear configuración
❌ Logs con info sensible
❌ Mutar parámetros
❌ Side effects ocultos
❌ Deep nesting (>3 niveles)

## WHAT TO ALWAYS DO

✅ Validar inputs en boundaries
✅ Logs estructurados con contexto
✅ Manejar todos los errores explícitos
✅ Tests para lógica crítica
✅ Documentar APIs públicas
✅ Pensar en edge cases
✅ Considerar concurrencia
✅ Pensar en escala
✅ Backups antes de cambios grandes
✅ Pull antes de push
✅ Branch para features grandes
✅ Reviews de código importante

## FINAL RULE

Si tenés que elegir entre:

- Código que funciona pero sucio
- Código limpio que toma más tiempo

→ ELEGÍ LIMPIO. SIEMPRE.

El código se lee 10 veces más
de lo que se escribe.

-----

*Skill version 2.0 — Production Grade*
