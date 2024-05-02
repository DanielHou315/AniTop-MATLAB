# Theory behind the Tops Project

## Tops

## Hamiltonian Mechanics

## Rotation in Space

### Euler Angles

Euler Angles have 3 components: $\phi, \theta, \psi$, representing the angle between our object and 3 respective axes.

#### Gimble Lock Problem

Euler Angles are susceptible to Gimble Locking, so it is not as often used in real-world implementations, especially when computers are involved. We use Quaternions instead to compute rotations.

### Quaternion

Quaternion is another way of representing rotation in 3D space. The idea behind this is that each rotation can be modeled by a **2D rotation around some fixed axis perpendicular to the rotation plane where the point of rotation lives**.

Formally, a quaternion is expressed in the form $q = q_0+q_1 i+q_2 j + q_3 k$, where $q_0, q_1, q_2, q_3$ are real numbers. The entire quaternion $q$ has 1 real part and 3 imaginary parts.

Quaternions can convert to/from Euler Angles with the following formulae:

Sources:

1. [Quaternion - Wikipedia](https://en.wikipedia.org/wiki/Quaternion)
2. [Conversions between Quaternions and Euler Angle](https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles)

## Euler Top

From introductory Physics, We know that for a rotating object, $T = \frac{1}{2} I \omega^2$. We can extend that to 3 dimension and model the system energy of an Euler top as

$$
    H = T + V \frac{1}{2}(I_1 \omega_1^2 + I_2 \omega_2^2 + I_3 \omega_3^2)
$$

From this, we can derive the following differential equations

```math
   \begin{bmatrix}
    \dot \omega_1 \\ \dot \omega_2 \\ \dot \omega_3
    \end{bmatrix} = \begin{bmatrix}
        (I_2 - I_3) I_1 \cdot \omega_2 \omega_3 \\ 
        (I_3 - I_1) / I_2 \cdot \omega_1 \omega_3 \\ 
        (I_1 - I_2) / I_3 \cdot \omega_1 \omega_2
    \end{bmatrix} 
```

Solving them will give us angular velocity as a function of time (in the discrete case of our simulation, a series of angular velocities corresponding to each time step). Then, we can convert to Euler angle rates with 

```math
    \begin{bmatrix}
         \dot \phi(t) \\ \dot \theta(t) \\ \dot \psi(t)
    \end{bmatrix} 
    = 
    \begin{bmatrix}
        \frac{\sin(\psi)}{\sin(\theta)} & \frac{\cos(\psi)}{\sin(\theta)} & 0 \\ 
        \cos(\theta) & \sin(\psi) & 0 \\
        -\frac{\cos(\theta) \sin(\psi)}{\sin(\theta)} & - \frac{\cos(\theta) \cos(\psi)}{\sin(\theta)} & 1
    \end{bmatrix}
    \cdot
    \begin{bmatrix} \omega_1(t) \\ \omega_2(t) \\ \omega_3(t) \end{bmatrix}
```

Finally, we integrate with respect to time to get the Euler angles of the Euler top over time.

```math
    \begin{bmatrix}
        \phi(t) \\ \theta(t) \\ \psi(t) 
    \end{bmatrix} = \sum_{i=1}^t (\Delta t \cdot 
    \begin{bmatrix}
         \dot \phi(t) \\ \dot \theta(t) \\ \dot \psi(t)
    \end{bmatrix})
```

## Lagrange Top


The Hamiltonian for the Lagrange top can be modeled as

```math
    H = T + V = \frac{P_\theta}{2I_1} + \frac{(P_\phi - P_\psi \cos^2(\theta))^2}{2I_1 \sin^2(\theta)} + \frac{P_\phi ^2}{2I_3} + MgL\cos(\theta)
```

Thus, we can derive the following differential equations:

```math
    \begin{align}
        \frac{d\phi}{dt} &= \frac{b - a \cos(\theta)}{\sin^2(\theta)}, \\
        \frac{d\psi}{dt} &= a \frac{I_1}{I_3} - \frac{(b - a\cos(\theta))\cos(\theta)}{\sin^2(\theta)}, \\
        \frac{d^2\theta}{dt^2} &= \frac{(a^2+b^2)\cos(\theta)}{\sin^3(\theta)} - a b \frac{3+\cos(2\theta)}{2\sin^3(\theta)} + \frac{\beta}{2}\sin(\theta).
    \end{align}
```

Note that the 2nd-order ODE is not solvable numerically with MATLAB, so we must convert that into a system of 1st order ODEs. Thus, we obtain the following differential equations to solve for:

```math
    \begin{align}
        \frac{d\phi}{dt} &= \frac{b - a \cos(\theta)}{\sin^2(\theta)}, \\
        \frac{d\theta}{dt} &= d\theta, \\
        \frac{d\psi}{dt} &= a \frac{I_1}{I_3} - \frac{(b - a\cos(\theta))\cos(\theta)}{\sin^2(\theta)}, \\
        \frac{d^2\theta}{dt^2} &= \frac{(a^2+b^2)\cos(\theta)}{\sin^3(\theta)} - a b \frac{3+\cos(2\theta)}{2\sin^3(\theta)} + \frac{\beta}{2}\sin(\theta).
    \end{align}
```
which directly solves us the Euler angles. 


## Kovalevskaya Top

For the Kovalevskaya top, we can obtain a similar set of differential equations

```math
    \begin{align}
        \frac{d\Phi}{dt} &= \frac{p_{\Phi} - p_{\Psi} \cos(\theta)}{I\sin^2(\theta)}, \\
        \frac{d\Theta}{dt} &= \frac{p_{\Theta}}{I}, \\
        \frac{d\Psi}{dt} &= -\frac{p_{\Psi}}{2I} - \frac{(p_{\Theta} - p_{\Psi})\cos(\theta)}{2I\sin^2(\theta)}, \\
        \frac{dP_{\Theta}}{dt} &= -\frac{(p_{\Theta} - p_{\Psi}\cos(\theta)) p_{\Psi}\sin(\theta)}{2I\sin^2(\theta)} + \frac{(p_{\Phi} - p_{\Psi}\cos(\theta))^2}{2I\sin^3(\theta)}\cos(\theta) - mga\cos(\theta)\sin(\psi), \\
        \frac{dP_{\Psi}}{dt} &= -mga \sin(\theta) \cos(\psi).
    \end{align}
```
which directly solves us the Euler angles. 
