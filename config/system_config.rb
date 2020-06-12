class SystemConfig


  @@internal_domain = 'engines.internal'


  def SystemConfig.internal_domain
    @@internal_domain
  end

    @@EnginesTopLevel = '/tmp/engines'
    @@ManagedServiceMountsFile = 'config/create_mounts/services.yaml'
    @@RunDir = "#{@@EnginesTopLevel}/run/"
    @@CidDir = "#{@@EnginesTopLevel}/run/cid/"
    @@ContainersDir = "#{@@EnginesTopLevel}/run/apps/"
    @@DeploymentDir = '/home/engines/deployment/deployed'
    @@DeploymentTemplates = "#{@@EnginesTopLevel}/system/templates/deployment"
    @@CONTFSVolHome = '/home/app/fs'
    @@LocalFSVolHome = '/tmp/var/lib/engines/apps' 
    @@ServiceFSVolHome = '/tmp/var/lib/engines/services'
    @@galleriesDir = "#{@@EnginesTopLevel}/etc/galleries"
    @@SystemLogRoot = '/var/log/engines/'
    @@ServiceMapTemplateDir = "#{@@EnginesTopLevel}/etc/services/mapping/"
    @@ServiceTemplateDir = "#{@@EnginesTopLevel}/etc/services/providers/"
    @@EnginesTemp = "#{@@EnginesTopLevel}/tmp"
    @@InfoTreeDir = "#{@@EnginesTopLevel}/run/public/services"
  
    @@DomainsFile = "#{@@EnginesTopLevel}/etc/domains/domains"
    @@timeZone_fileMapping = ' -v /etc/localtime:/etc/localtime:ro '
    @@NoRemoteExceptionLoggingFlagFile = "#{@@EnginesTopLevel}/run/system/flags/no_remote_exception_log"
    @@SSHStore = "#{@@EnginesTopLevel}/etc/ssh/keys"
  
    @@KeysDestination = '/home/engines/etc/ssl/keys/'
    @@CertAuthTop = '/tmp/var/lib/engines/services/certs/store/live/'
    @@CertificatesDestination = '/home/engines/etc/ssl/certs/'
    @@ServiceBackupScriptsRoot = '/home/engines/scripts/backup/'
    @@EngineServiceBackupScriptsRoot = '/home/engines/scripts/backup/engine/'
    
    #Container UID historical store
    @@ContainerUIDdir = "#{@@EnginesTopLevel}/etc/containers/uids"
    @@ContainerNextUIDFile = "#{@@EnginesTopLevel}/etc/containers/uids/next"
    
    @@BackupTmpDir = '/tmp/backup_bundles/'
     
    def SystemConfig.ServiceFSVolHome
       @@ServiceFSVolHome
    end
     def SystemConfig.ManagedServiceMountsFile
       @@ManagedServiceMountsFile
     end
     
     def SystemConfig.BackupTmpDir
       @@BackupTmpDir
     end
     
    def SystemConfig.ContainerUIDdir
      @@ContainerUIDdir
    end
    def SystemConfig.ContainerNextUIDFile
      @@ContainerNextUIDFile
    end
    
    def SystemConfig.EngineServiceBackupScriptsRoot
      @@EngineServiceBackupScriptsRoot
    end
    def SystemConfig.ServiceBackupScriptsRoot
      @@ServiceBackupScriptsRoot
    end
  
    def SystemConfig.InfoTreeDir
      @@InfoTreeDir
    end
  
    def SystemConfig.CertAuthTop
      @@CertAuthTop
    end
  
    def SystemConfig.SSHStore
      @@SSHStore
    end
  
    def SystemConfig.CertificatesDestination
      @@CertificatesDestination
    end
  
  
    def SystemConfig.KeysDestination
      @@KeysDestination
    end
  
    def SystemConfig.ServiceMapTemplateDir
      @@ServiceMapTemplateDir
    end
  
    def SystemConfig.EnginesTemp
      @@EnginesTemp
    end
  
    def SystemConfig.ServiceTemplateDir
      @@ServiceTemplateDir
    end
  
    def SystemConfig.SystemLogRoot
      @@SystemLogRoot
    end
  
    def SystemConfig.galleriesDir
      @@galleriesDir
    end
  
    def SystemConfig.ContainersDir
      @@ContainersDir
    end
  
    def SystemConfig.LocalFSVolHome
      @@LocalFSVolHome
    end
  
    def SystemConfig.CONTFSVolHome
      @@CONTFSVolHome
    end
  
    def SystemConfig.DeploymentTemplates
      @@DeploymentTemplates
    end
  
    def SystemConfig.CidDir
      @@CidDir
    end
  
    def SystemConfig.DeploymentDir
      @@DeploymentDir
    end
  
    def SystemConfig.RunDir
      @@RunDir
    end
  
    def SystemConfig.SystemLogRoot
      @@SystemLogRoot
    end
  
  
end