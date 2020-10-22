Pod::Spec.new do |s|
    
    s.name = 'Champi'
    s.version = '1.0.0'

    s.summary = ''
    s.description = <<-DESC
                    
                    DESC

    s.authors = { 'spirit-jsb' => 'sibo_jian_29903549@163.com' }
    s.license = 'MIT'
    
    s.homepage = 'https://github.com/spirit-jsb/Champi.git'

    s.ios.deployment_target = '10.0'

    s.swift_versions = ['5.0']

    s.frameworks = ''

    s.source = { :git => 'https://github.com/spirit-jsb/Champi.git', :tag => s.version }

    s.default_subspecs = ''
    
    s.subspec '' do |sp|
        sp.source_files = 
    end

end