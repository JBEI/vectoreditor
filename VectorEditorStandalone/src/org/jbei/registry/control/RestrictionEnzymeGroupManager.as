package org.jbei.registry.control
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.RestrictionEnzyme;
	import org.jbei.bio.data.RestrictionEnzymeGroup;
	import org.jbei.registry.models.UserRestrictionEnzymeGroup;
	import org.jbei.registry.models.UserRestrictionEnzymes;
	
	public final class RestrictionEnzymeGroupManager
	{
        private static var _instance:RestrictionEnzymeGroupManager = new RestrictionEnzymeGroupManager();
        
		private var rebaseEnzymesDatabase:Dictionary /* {RestrictionEnzyme.Name : RestrictionEnzyme} */ = new Dictionary();
		private var isInitialized:Boolean = false;
		
        private var _systemGroups:ArrayCollection /* of RestrictionEnzymeGroup */ = new ArrayCollection();
        private var _userGroups:ArrayCollection /* of RestrictionEnzymeGroup */ = new ArrayCollection();
        private var _activeGroup:ArrayCollection /* of RestrictionEnzyme */ = new ArrayCollection();
		
		// Constructor
		public function RestrictionEnzymeGroupManager()
		{
            if (_instance != null) {
                throw new Error("RestrictionEnzymeGroupManager can only be accessed through RestrictionEnzymeGroupManager.instance");
            }
		}
		
		// Properties
        public static function get instance():RestrictionEnzymeGroupManager
        {
            return _instance;
        }
        
        public function get systemGroups():ArrayCollection /* of RestrictionEnzymeGroup */
        {
        	return _systemGroups;
        }
        
        public function set systemGroups(value:ArrayCollection /* of RestrictionEnzymeGroup */):void
        {
        	_systemGroups = value;
        }
        
        public function get userGroups():ArrayCollection /* of RestrictionEnzymeGroup */
        {
        	return _userGroups;
        }
        
        public function set userGroups(value:ArrayCollection /* of RestrictionEnzymeGroup */):void
        {
        	_userGroups = value;
        }
        
        public function get activeGroup():ArrayCollection /* of RestrictionEnzyme */
        {
        	return _activeGroup;
        }
        
        public function set activeGroup(value:ArrayCollection /* of RestrictionEnzyme */):void
        {
        	_activeGroup = value;
        }
        
		// Public Methods
		public function loadRebaseDatabase(rebaseEnzymesCollection:ArrayCollection /* of RestrictionEnzyme */):void
		{
			if(isInitialized) {
				throw new Error("REBASE database already initialized!");
			}
			
			if(!rebaseEnzymesCollection || rebaseEnzymesCollection.length == 0) {
				return;
			}
			
			for(var i:int = 0; i < rebaseEnzymesCollection.length; i++) {
				var enzyme:RestrictionEnzyme = rebaseEnzymesCollection.getItemAt(i) as RestrictionEnzyme;
				
				rebaseEnzymesDatabase[enzyme.name.toLowerCase()] = enzyme;
			}
			
			isInitialized = true;
			
			registerSystemGroups();
			initializeDefaultActiveGroup();
		}
		
		public function loadUserRestrictionEnzymes(userRestrictionEnzymes:UserRestrictionEnzymes):void
		{
			// load user groups
			_userGroups.removeAll();
			
			if(!userRestrictionEnzymes || (userRestrictionEnzymes && userRestrictionEnzymes.activeEnzymeNames == null && userRestrictionEnzymes.groups == null)) {
				return;
			}
			
			if(userRestrictionEnzymes.groups && userRestrictionEnzymes.groups.length > 0) {
				for(var i:int = 0; i < userRestrictionEnzymes.groups.length; i++) {
					var userRestrictionEnzymeGroup:UserRestrictionEnzymeGroup = userRestrictionEnzymes.groups.getItemAt(i) as UserRestrictionEnzymeGroup;
					
					if(!userRestrictionEnzymeGroup || !userRestrictionEnzymeGroup.groupName || !userRestrictionEnzymeGroup.enzymeNames || userRestrictionEnzymeGroup.enzymeNames.length == 0) {
						continue;
					}
					
					var newUserGroup:RestrictionEnzymeGroup = createGroupByEnzymes(userRestrictionEnzymeGroup.groupName, userRestrictionEnzymeGroup.enzymeNames.toArray());
					_userGroups.addItem(newUserGroup);
				}
			}
			
			// load user active group
			_activeGroup.removeAll();
			
			if(userRestrictionEnzymes.activeEnzymeNames && userRestrictionEnzymes.activeEnzymeNames.length > 0) {
				var activeEnzymeNames:RestrictionEnzymeGroup = createGroupByEnzymes("tmpActive", userRestrictionEnzymes.activeEnzymeNames.toArray());
				_activeGroup.addAll(activeEnzymeNames.enzymes);
			}
		}
		
		public function removeGroup(restrictionEnzymeGroup:RestrictionEnzymeGroup):void
		{
			for(var i:int = 0; i < userGroups.length; i++) {
				var userGroup:RestrictionEnzymeGroup = userGroups[i];
				
				if(userGroup == restrictionEnzymeGroup) {
					userGroups.removeItemAt(i);
					
					return;
				}
			}
		}
		
		public function groupByName(name:String):RestrictionEnzymeGroup
		{
			var resultGroup:RestrictionEnzymeGroup = null;
			
			for(var i:int = 0; i < userGroups.length; i++) {
				var userGroup:RestrictionEnzymeGroup = userGroups[i];
				
				if(userGroup.name == name) {
					resultGroup = userGroup;
					
					break;
				}
			}
			
			return resultGroup;
		}
		
		public function createGroupByEnzymes(name:String, collection:Array /* of String */):RestrictionEnzymeGroup
		{
			if(!isInitialized) {
				throw new Error("REBASE database wasn't initialized yet!");
			}
			
			var newGroup:RestrictionEnzymeGroup = new RestrictionEnzymeGroup(name);
			
			if(collection && collection.length > 0) {
				for(var i:int = 0; i < collection.length; i++) {
					var enzymeName:String = collection[i];
					
					if(!enzymeName || enzymeName == "") {
						continue;
					}
					
					var enzyme:RestrictionEnzyme = rebaseEnzymesDatabase[enzymeName.toLowerCase()];
					
					if(!enzyme) {
						continue;
					}
					
					newGroup.addRestrictionEnzyme(enzyme);
				}
			}
			
			return newGroup;
		}
		
        // Private Methods
        private function initializeDefaultActiveGroup():void
        {
			for(var i:int = 0; i < (_systemGroups[0] as RestrictionEnzymeGroup).enzymes.length; i++) {
				activeGroup.addItem((_systemGroups[0] as RestrictionEnzymeGroup).enzymes[i]);
			}
        }
		
		private function registerSystemGroups():void
		{
			// 1. Common
			var commonGroup:RestrictionEnzymeGroup = createGroupByEnzymes("Common", new Array("AatII", "AvrII", "BamHI", "BglII", "BsgI", "EagI", "EcoRI", "EcoRV", "HindIII", "KpnI", "MseI", "NcoI", "NdeI", "NheI", "NotI", "PstI", "PvuI", "SacI", "SacII", "SalI", "SmaI", "SpeI", "SphI", "XbaI", "XhoI", "XmaI"));
			_systemGroups.addItem(commonGroup);
			
			// 2. REBASE
			var rebaseGroup:RestrictionEnzymeGroup = new RestrictionEnzymeGroup("REBASE");
			
			for each (var enzyme:RestrictionEnzyme in rebaseEnzymesDatabase) {
				rebaseGroup.addRestrictionEnzyme(enzyme);
			}
			
			_systemGroups.addItem(rebaseGroup);
			
			// 3. Berkeley Biobrick
			var berkeleyBBGroup:RestrictionEnzymeGroup = createGroupByEnzymes("Berkeley BioBricks", new Array("EcoRI", "BglII", "BamHI", "XhoI"));
			_systemGroups.addItem(berkeleyBBGroup);
			
			// 4. MIT Biobrick
			var mitBBGroup:RestrictionEnzymeGroup = createGroupByEnzymes("MIT BioBricks", new Array("EcoRI", "XbaI", "SpeI", "PstI"));
			_systemGroups.addItem(mitBBGroup);
			
			// 5. Fermentas Fast Digest
			var fermentasFastDigestBBGroup:RestrictionEnzymeGroup = createGroupByEnzymes("Fermentas Fast Digest", new Array("AatII", "Acc65I", "AccI", "AciI", "AclI", "AcuI", "AfeI", "AflII", "AgeI", "AjuI", "AleI", "AluI", "Alw21I", "Alw26I", "AlwNI", "ApaI", "ApaLI", "AscI", "AseI", "AsiSI", "AvaI", "AvaII", "AvrII", "BamHI", "BanI", "BbsI", "BbvI", "BclI", "BfaI", "BglI", "BglII", "BlpI", "Bme1580I", "BmtI", "BplI", "BpmI", "Bpu10I", "BsaAI", "BsaBI", "BsaHI", "BsaJI", "BseGI", "BseNI", "BseXI", "Bsh1236I", "BsiEI", "BsiWI", "BslI", "BsmBI", "BsmFI", "Bsp119I", "Bsp120I", "Bsp1286I", "Bsp1407I", "BspCNI", "BspHI", "BspMI", "BsrBI", "BsrDI", "BsrFI", "BssHII", "BstXI", "BstZ17I", "Bsu36I", "ClaI", "Csp6I", "DdeI", "DpnI", "DraI", "DraIII", "DrdI", "EagI", "Eam1105I", "EarI", "Ecl136II", "Eco31I", "Eco91I", "EcoNI", "EcoO109I", "EcoRI", "EcoRV", "EheI", "Fnu4HI", "FokI", "FspAI", "FspI", "HaeII", "HaeIII", "HgaI", "HhaI", "HincII", "HindIII", "HinfI", "HinP1I", "HpaI", "HpaII", "Hpy8I", "HpyF10VI", "Kpn2I", "KpnI", "MauBI", "MboI", "MboII", "MfeI", "MluI", "MlyI", "MnlI", "MreI", "MscI", "MseI", "MslI", "MspI", "MssI", "Mva1269I", "MvaI", "NaeI", "NciI", "NcoI", "NdeI", "NheI", "NlaIII", "NlaIV", "NmuCI", "NotI", "NruI", "NsiI", "NspI", "PacI", "PdmI", "PflMI", "PfoI", "PmlI", "PpuMI", "PshAI", "PsiI", "PspFI", "PstI", "PsuI", "PsyI", "PvuI", "PvuII", "RsaI", "RsrII", "SacI", "SalI", "SanDI", "SapI", "Sau3AI", "Sau96I", "SbfI", "ScaI", "ScrFI", "SexAI", "SfaNI", "SfcI", "SfiI", "SmaI", "SnaBI", "SpeI", "SphI", "SspI", "StuI", "StyI", "SwaI", "TaaI", "TaiI", "TaqI", "TatI", "TauI", "TfiI", "Tru1I", "Tsp509I", "TspRI", "XapI", "XbaI", "XhoI"));
			_systemGroups.addItem(fermentasFastDigestBBGroup);
		}
	}
}
