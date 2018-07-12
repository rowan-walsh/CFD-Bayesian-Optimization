for ii in range(len(expressions)):
    for jj in range(len(expressions[0])):
        if needsUpdates[ii][jj]:
            designPoints[jj].SetParameterExpression(parameters[ii], expressions[ii][jj])

system1 = GetSystem(Name="CFX")
setupComponent1 = system1.GetComponent(Name="Setup")
for desi in designPoints:
    if Parameters.GetBaseDesignPoint() != desi:
        Parameters.SetBaseDesignPoint(DesignPoint=desi)
    try:
        setupComponent1.UpdateUpstreamComponents()
    except:
        pass

