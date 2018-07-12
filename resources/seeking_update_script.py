import sys
import os
sys.path.append(os.path.abspath(resourcesPath))
import LinAlg as la

maxTrials = 5
unfitTrials = 3
CFDnLowRes = 75
CFDnHighRes = 150
CFDguessedSlope = -0.0004
unfitRelaxFactor = 0.5

seekDerivPolynomial = la.polyDeriv(seekPolynomial)
inputUnits = inputParameter.Value.Unit
f = open(GetProjectDirectory() + '\\operatingPointDebug.txt', 'a')

# For each design point in the list:
for desi in designPoints:
    # Write header for this design point to debug file
    f.write('# DP' + desi.Name + '\n')
    f.write('# ' + str(DateTime.Now) + '\n')
    f.write('# n,x,y,net\n')

    # Initialize
    n = []
    x = []
    y = []
    net = []
    errorFlag = False
    errorType = ''
    linearFitUsed = []

    # Set base design point to desi, unless it already is
    if desi != Parameters.GetBaseDesignPoint():
        Parameters.SetBaseDesignPoint(DesignPoint=desi)

    # Run trials
    for i in range(maxTrials):
        # Decide new trial inputs and iterations amount
        if i == 0:  # First trial
            nNext = CFDnLowRes
            xNext = desi.GetParameterValue(inputParameter).Value
        elif i < unfitTrials:  # Trials before curve fitting
            if i == 1:  # Second trial, guessed slope
                slope = CFDguessedSlope - la.polyVal(seekDerivPolynomial, x[i-1])
            else:
                slope = (y[i-1] - y[i-2])/(x[i-1] - x[i-2]) - la.polyVal(seekDerivPolynomial, x[i-1])

            nNext = CFDnLowRes
            xNext = x[i-1] - unfitRelaxFactor*(net[i-1]/slope)
        else:  # Trials with curve fitting
            try:
                fit = la.polyFit(x, net, 2)
            except Exception:
                errorFlag = True
                errorType = 'polyFit failed in trial ' + str(i)
                break

            try:
                zero = la.newtonsMethod(fit, x[i-1])
            except Exception:  # Try a linear fit
                try:
                    fit = la.polyFit(x, net, 1)
                    zero = la.newtonsMethod(fit, x[i-1])
                    linearFitUsed.append(i)
                except Exception:
                    errorFlag = True
                    errorType = 'newton\'s method failed in trial ' + str(i)
                    break

            if i == maxTrials-1:
                nNext = CFDnHighRes  # If last trial, set to highRes
            else:
                nNext = CFDnLowRes
            xNext = zero

        # Save new trial inputs
        n.append(nNext)
        x.append(xNext)

        # Save trial inputs to debug file
        f.write(str(n[i]) + ',')
        f.write(str(x[i]) + ',')

        # Update design point with input
        desi.SetParameterExpression(
            Parameter=iterationsParameter,
            Expression=str(n[i]))
        desi.SetParameterExpression(
            Parameter=inputParameter,
            Expression=(str(x[i]) + ' [' + inputUnits + ']'))

        # Simulate trial
        try:
            backgroundSession1 = UpdateAllDesignPoints(DesignPoints=[desi])
        except Exception:
            errorFlag = True
            errorType = 'design point update failed in trial ' + str(i)
            f.write('\n')
            break

        # Get trial outputs, save to debug file
        y.append(desi.GetParameterValue(outputParameter).Value)
        net.append(y[i] - la.polyVal(seekPolynomial, x[i]))
        f.write(str(y[i]) + ',')
        f.write(str(net[i]) + ',')
        f.write('\n')

    # Add line to debug file describing seek outcome
    if errorFlag:
        f.write('# Seek failed (' + errorType + ')\n')
        desi.Retained = False
    else:
        f.write('# Seek succeeded')
        if len(linearFitUsed) > 0:
            f.write(', linear fit used in trial(s) ' + str(linearFitUsed))
        f.write('\n')

    # Add blank line to debug file
    f.write('\n')

# Close the debug file
f.close()
