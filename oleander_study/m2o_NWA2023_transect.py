from model2obs.workflows import WorkflowModelObs

# Create and run workflow to interpolate MOM6 model onto Oleander grid
workflow_crocolake = WorkflowModelObs.from_config_file('config_NWA12_2023_transect.yaml')
workflow_crocolake.run(clear_output=True, parallel=True) #use flag clear_output=True if you want to re-run it and automatically clean all previous output
